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

1. Networks containing proxy server with SSL and/or Man In The Middle (MITM) proxy
2. On-premise resources requiring SSL
3. nonProxyHost required for on-premise resources
4. White list OMCS and upgrade URIs

It’s important to note that future releases of ICS may improve on these configuration challenges. However, some are not related to the product (e.g., network white list) and appropriate actions will need to be coordinated with the on-premise teams (e.g., network administrators).

### Import Certificates

One of the more challenging activities with post-configuration of the ICS Connectivity Agent is updating the keystore with Certificates that the agent needs to trust. Since the agent is a lightweight, single server, WebLogic installation, there are no web consoles available to help with the certificate import. However, if you investigate this topic on the internet you will eventually end up with details on using java keytool and WebLogic WLST to accomplish this task. Instead of doing all this research, I am including a set of scripts (bash and WLST) that can be used to expedite the process. The scripts are comprised of 4 files where each file contains a header that provides details on how the script works and its role in the process. Once downloaded, please review these headers to make yourself familiar with what is required and how they work together.

The following is a step-by-step example on using these scripts:

1. Download the scripts into a directory on the machine where the Connectivity Agent is running
2. Update the importToAgentEnv.sh to reflect your agent environment
3. Create a subdirectory that will be used to hold all the certificates that will need to be imported to the agent keystore
4. Download or copy all certificates in the chain to the directory created in the previous step
5. Execute the createKeystore.sh (NOTE: This script has created a file called importToAgent.ini that contains details that will be used by the importToAgent.py WLST script)
6. Make sure your agent server is running and execute the importToAgent.sh

At this point you will have imported the certificates into the keystore of the running Connectivity Agent. I always bounce the agent server to make sure it starts cleanly and everything is picked up fresh.

### For Complete Details, See Blog:

http://www.ateam-oracle.com/ics-connectivity-agent-advanced-configuration/
