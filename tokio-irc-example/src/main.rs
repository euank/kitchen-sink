extern crate tokio_irc_client;
extern crate futures;
extern crate tokio_core;
extern crate pircolate;

use std::net::ToSocketAddrs;
use tokio_core::reactor::Core;
use futures::future::Future;
use futures::Stream;
use futures::Sink;

use tokio_irc_client::Client;
use pircolate::message;
use pircolate::command::PrivMsg;

fn main() {
    // Create the event loop
    let mut ev = Core::new().unwrap();
    let handle = ev.handle();

    let addr = "irc.wobscale.website:6667"
        .to_socket_addrs()
        .unwrap()
        .next()
        .unwrap();

    let c = Client::new(addr).connect(&handle);

    let connected = c.and_then(|irc| {
        println!("nick");
        irc.send(message::client::nick("rstest").unwrap())
    }).and_then(|stream| {
            println!("user");
            stream.send(message::client::user("rstest", "rstest").unwrap())
        });

    let joined = connected.and_then(|irc| {
        let (send, recv) = irc.split();
        let skipped = recv.skip_while(|msg| {
            match msg.raw_command() {
                "422" => {
                    println!("Got an ERR_NOMOTD");
                    Ok(false)
                }
                "376" => {
                    println!("Got an RPL_ENDOFMOTD");
                    Ok(false)
                }
                _ => Ok(true), // keep waiting for welcome
            }
        });

        skipped
            .into_future()
            .map_err(|res| res.0)
            .and_then(|(_, s)| Ok((send, s)))
    });

    let bot = joined.and_then(|(send, recv)| {
        println!("join");
        send.send(message::client::join("#seubot", None).unwrap())
            .and_then(|send| {
                recv.filter_map(|msg| {
                    println!("{:?}", msg);
                    match msg.command() {
                        Some(PrivMsg(_, msg)) => {
                            if msg.starts_with("!test ") || msg == "!test" {
                                return Some(message::client::priv_msg("#seubot", "test command called").unwrap());
                            }
                        },
                        _ => {},
                    };
                    None
                }).fold(send, |send, msg| {
                    return send.send(msg);
                })
            })
    });

    ev.run(bot).unwrap();
}
