## Spin Cycle

Testing chef-client to destruction, since 2015

### Motivation

To prevent Chef from releasing chef-client with glaring regressions or
problems it is necessary to test actual live software and cookbooks.
This project aims to build, test and destroy a set of systems that
utilise as wide a range of cookbooks and plugins as possible.

Right now, we utilise chef-provisioning on a completely clean node to set up the test systems, and then spin a range of ubuntu and centos machines to test various recipes. 

### Set up

We strongly advise using chefdk to run this, so as to provide a stable
environment for your tests.
You ideally need a spare organisation for this to work, so create one on
hosted chef, and get a config file and pem file in the usual way.
Your clients also need to be able to create other clients.

```
knife group add group clients admins
```

Once you've done that, get spin cycle ready by telling it about your
chef server and user, and syncing your cookbooks to your org:

```
chef exec ./spincycle.rb configure -u https://your/chef/server -c you -k your.pem
chef exec ./spincycle.rb sync
```

In AWS IAM, create a role named `spincycle_provisioner` and give it full
access to EC2.

### Launch!

You're ready to go:

```
chef exec ./spincycle.rb launch -x an_ssh_key chef_version
```

