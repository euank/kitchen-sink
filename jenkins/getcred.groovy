// This is an example of how to get a 'Secret text' credential from the '/script' console on jenkins.
// To get other credentials, the class used below and the 'getSecret()' method are liable to need changing.
def id = "ID";
def creds = com.cloudbees.plugins.credentials.CredentialsProvider.lookupCredentials(
    org.jenkinsci.plugins.plaincredentials.StringCredentials.class,
    Jenkins.instance,
  	null,
  	null
);

def c = creds.find { it.id == id };
println(c.id + ": " + c.getSecret());
