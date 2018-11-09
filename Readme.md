# ICS Connectivity Agent Scripts



This Asset contains

- Blog Article available at ATeam Chronicles

  - http://www.ateam-oracle.com/ics-connectivity-agent-advanced-configuration/

- Sample Scripts
  - [Advanced Configuration Scripts](./advancedConfigScripts)
  - [Credential Configuration Scripts](./credentialScripts ) No Longer Needed ... for informational/historic purposes only.

- Advanced Configuration Script History
  - Version 1.1 removed the Agent Password from the importToAgent.sh bash script and implemented a prompt

------



## ICS Connectivity Agent Advanced Configuration

Oracle’s Integration Cloud Service (ICS) provides a feature that helps with the integration challenge of cloud to ground integrations with resources behind a firewall. This feature is called the ICS Connectivity Agent (additional details about the Agent can be found under [New Agent Simplifies Cloud to On-premises Integration](https://blogs.oracle.com/integration/entry/new_agent_simplifies_cloud_to)). The design of the Connectivity Agent is to provide a safe, simple, and quick setup for ICS to on-premise resources. In many cases this installation and configuration is an almost no-brainer activity. However, there are edge cases and network configurations that make this experience a bit more challenging.

We have encountered the following post-installation challenges with the ICS 16.3.5 Connectivity Agent:

| 1.   | Networks containing proxy server with SSL and/or Man In The Middle (MITM) proxy |
| ---- | ---------------------------------------- |
| 2.   | On-premise resources requiring SSL       |
| 3.   | nonProxyHost required for on-premise resources |
| 4.   | White list OMCS and upgrade URIs         |

It’s important to note that future releases of ICS may improve on these configuration challenges. However, some are not related to the product (e.g., network white list) and appropriate actions will need to be coordinated with the on-premise teams (e.g., network administrators).

### Import Certificates

One of the more challenging activities with post-configuration of the ICS Connectivity Agent is updating the keystore with Certificates that the agent needs to trust. Since the agent is a lightweight, single server, WebLogic installation, there are no web consoles available to help with the certificate import. However, if you investigate this topic on the internet you will eventually end up with details on using java keytool and WebLogic WLST to accomplish this task. Instead of doing all this research, I am including a set of scripts (bash and WLST) that can be used to expedite the process. The scripts are comprised of 4 files where each file contains a header that provides details on how the script works and its role in the process. Once downloaded, please review these headers to make yourself familiar with what is required and how they work together.

The following is a step-by-step example on using these scripts:

| 1.   | Download the scripts archive on the machine where the Connectivity Agent is runningScripts: [importToAgent.tar](http://www.ateam-oracle.com/wp-content/uploads/2016/10/importToAgent.tar.gz) |
| ---- | ---------------------------------------- |
| 2.   | Extract the scripts archive into a directory. For example: |

| 3.   | Update the importToAgentEnv.sh to reflect your agent environment |
| ---- | ---------------------------------------- |
| 4.   | Create a subdirectory that will be used to hold all the certificates that will need to be imported to the agent keystore: |

| 5.   | Download or copy all certificates in the chain to the directory created in the previous step: |
| ---- | ---------------------------------------- |
|      |                                          |

|      | NOTE: You can use your browser to export the certificates if you do not have them available elsewhere. Simply put the secured URL in the browser and then access the certificates from the “lock”: |
| ---- | ---------------------------------------- |
|      |                                          |

[![AdvancedAgentConfig-002](http://www.ateam-oracle.com/wp-content/uploads/2016/10/AdvancedAgentConfig-002.png)](http://www.ateam-oracle.com/wp-content/uploads/2016/10/AdvancedAgentConfig-002.png)

| 6.   | Execute the createKeystore.sh: |
| ---- | ------------------------------ |
|      |                                |

NOTE: This script has created a file called importToAgent.ini that contains details that will be used by the importToAgent.py WLST script. Here’s an example of what it looks like:

| 7.   | Make sure your agent server is running and execute the importToAgent.sh: |
| ---- | ---------------------------------------- |
|      |                                          |

At this point you will have imported the certificates into the keystore of the running Connectivity Agent. I always bounce the agent server to make sure it starts cleanly and everything is picked up fresh.

### Update http.nonProxyHost

If your network contains a proxy server, you will want to make sure that any on-premise resource the agent will be connecting to is on the http.nonProxyHosts list.  This way the agent knows to not use the proxy when trying to connect to an on-premise endpoint:

[![AdvancedAgentConfig-003](http://www.ateam-oracle.com/wp-content/uploads/2016/11/AdvancedAgentConfig-003.png)](http://www.ateam-oracle.com/wp-content/uploads/2016/11/AdvancedAgentConfig-003.png)

To update this Java option, open the $AGENT_DOMAIN/bin/setDomainEnv.sh and search for nonProxyHosts. Then add the appropriate host names to the list. For example:

#### Before

export JAVA_PROPERTIES=”${JAVA_PROPERTIES} **-Dhttp.nonProxyHosts=localhost|127.0.0.1** -Dweblogic.security.SSL.ignoreHostnameVerification=true -Djavax.net.ssl.trustStoreType=kss -Djavax.net.ssl.trustStore=kss://system/trust”

#### After

export JAVA_PROPERTIES=”${JAVA_PROPERTIES} **-Dhttp.nonProxyHosts=localhost|127.0.0.1****|\*.oracle.com** -Dweblogic.security.SSL.ignoreHostnameVerification=true -Djavax.net.ssl.trustStoreType=kss -Djavax.net.ssl.trustStore=kss://system/trust”

Once this update has been done, you will need to restart your agent server for the update to be picked up.

### Add Agent URIs to Network White List

The Connectivity Agent contains two URIs that it will reach out to. The primary one is Oracle Message Cloud Service (OMCS), which is how ICS communicates to the on-premise agent. The other one is for things like agent upgrades. These two URIs must be added to the network white list or the agent will not be able to receive requests from ICS. The URIs are located in the following Connectivity Agent file:

$AGENT_DOMAIN/agent/config/CpiAgent.properties

The contents of this file will look something like the following (with the URIs circled):

[![AdvancedAgentConfig-001](http://www.ateam-oracle.com/wp-content/uploads/2016/10/AdvancedAgentConfig-001.png)](http://www.ateam-oracle.com/wp-content/uploads/2016/10/AdvancedAgentConfig-001.png)

### Summary

Please follow the official on-line documentation for the ICS Connectivity Agent install. If you run into things like handshake errors when the agent starts or attempts to connect to an on-premise resource, the aforementioned will be a good starting point to resolve the issue. This blog most likely does not cover all edge cases, so if you encounter something outside of what is covered here I would like to hear about it.
