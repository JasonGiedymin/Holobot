# configure_origin.pp
class { 'openshift_origin' :
    #The DNS resolvable hostname of this host
    node_fqdn                  => "broker.localhost.localdomain",

    #The domain under which application should be created. Eg: <app>-<namespace>.example.com
    cloud_domain               => 'localhost.localdomain',

    #Upstream DNS server.
    # EC2 use: 172.16.0.23
    dns_servers                => ['8.8.8.8'],

    enable_network_services    => true,
    configure_firewall         => true,
    configure_ntp              => true,

    #Configure the required services
    configure_activemq         => true,
    configure_mongodb          => true,
    configure_named            => true,
    configure_avahi            => false,
    configure_broker           => true,
    configure_node             => true,

    #Enable development mode for more verbose logs
    development_mode           => true,

    #Update the nameserver on this host to point at Bind server
    update_network_dns_servers => true,

    #Use the nsupdate broker plugin to register application
    broker_dns_plugin          => 'nsupdate',

    #If installing from a local build, specify the path for Origin RPMs
    #install_repo               => '',

    #If using BIND, let the broker know what TSIG key to use
    named_tsig_priv_key         => 'Cye9AUKlSMDIh0Q30uZEAnsWzTobag==',

    #If using an external ethernet device other than eth0
    eth_device                 => 'p8p1',

    #If using with GDM, or have users with UID 500 or greater, add to this list
    #os_unmanaged_users         => ['gdm'],

    #If using the stable version instead of the nightly
    #install_repo               => 'release',
    #dependencies_repo          => 'release',
}