extern crate tokio_irc_client;
extern crate futures;
extern crate tokio_core;
extern crate pircolate;

use std::time;
use std::net::ToSocketAddrs;
use tokio_core::reactor::Core;
use futures::future::Future;
use futures::Stream;
use futures::Sink;
use futures::stream;
use futures::stream::SkipWhile;

use tokio_irc_client::Client;
use pircolate::message;
use pircolate::command::{PrivMsg, Welcome};

fn main() {
    // Create the event loop
    let mut ev = Core::new().unwrap();
    let handle = ev.handle();

    let addr = "irc.wobscale.website:6697".to_socket_addrs().unwrap().next().unwrap();

    let connect = Client::new(addr)
        .connect_tls(&handle, "irc.wobscale.website");

    let join_and_print = connect.and_then(|irc| {
        let connect_sequence = vec![message::client::nick("fjtest"),
        message::client::user("testfj", "testfj")];
        irc.send_all(stream::iter(connect_sequence))
    }).and_then(|(irc, res)| {
        let next = irc.skip_while(|msg| {
            match msg.command() {
                Some(Welcome(_, m)) => {
                    println!("Got a welcome: {}", m);
                    Ok(false)
                }
                _ => Ok(true), // keep waiting for welcome
            }
        });
        Ok((next, res))
    }).and_then(|(irc, res)| {
        irc.send_all(stream::iter(vec![message::client::join("#fj", None)]))
    }).and_then(|(irc, res)| {
        // let (send, recv) = irc.split();
        irc.for_each(|m| {
            println!("{:?}", m);
            // Note: neither `irc.send` nor `send.send` works here because it's already moved.
            // This includes if I use `recv.for_each` and then try to send with `send.send`. Wtf is
            // the point of splitting it if my lifetimes are still fuq'd?
            //send.send_all(stream::iter(vec![message::client::join("#fj", None)]));
            Ok(())
        })
    });

    ev.run(join_and_print).unwrap();
}
