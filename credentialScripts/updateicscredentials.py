#=========================================================================================
# Title:       updateicscredentials.py - ICS Connectivity Agent credential update
#
# Disclaimer:  This script is provided "AS IS" and without any official support
#              from Oracle. Its use needs to be performed using details from the
#              comments section and/or readme file (if one is included). Any bugs
#              encountered, feedback, and/or enhancement requests are welcome.
#
#              No liability for the contents of this script can be accepted. Use
#              the concepts, examples, and information at your own risk. However,
#              great care has been taken to ensure that all technical information
#              is accurate and as useful as possible.
#
#              Copyright © 2018, Oracle and/or its affiliates. All rights reserved.
#              The Universal Permissive License (UPL), Version 1.0
#
#
# Description: This script is used to update the credentials for a running Connectivity
#              Agent server. It is necessary to run this script whenever the ICS user
#              that was used during agent installation has changed their password. If this
#              is not done, the agent will appear to be running fine but the ICS console
#              will show the agent as down. Additionally, if the ICS user who used their
#              credentials for the agent installation tries to login to ICS they will be
#              temporarily locked out. This is due to the agent making multiple calls to
#              ICS with invalid credentials resulting in ICS locking out the user.
#
#
# Usage:       $AGENT_HOME/oracle_common/common/bin/wlst.sh $PATH_TO_SCRIPT/updateicscredentials.py adminUser adminPass agentT3URI icsUser icsPass
#
# Example:     ./wlst.sh /tmp/updateicscredentials.py weblogic welcome1 t3://localhost:7001 ics.user@example.com N3wP@55w0rd
#
# NOTES:       It is important that the agent server be running when this script is
#              executed.
#
#              After executing the script, shut the agent server down and wait for
#              approximately 30 minutes to allow the locked user account to unlock
#              before attempting to start the agent.
#
#=========================================================================================

import os
import sys
import shutil


adminUserName=sys.argv[1]
adminPassword=sys.argv[2]
adminURL=sys.argv[3]
icsUserName=sys.argv[4]
icsPassword=sys.argv[5]


try:
    connect(adminUserName, adminPassword, adminURL)
    updateCred(map="oracle.agent.patcher", key="AGENT_PATCHER_APPID", user=icsUserName, password=icsPassword, desc="Updating Agent Credential Store")
    disconnect()
except:
   print "Error updating credentials for AGENT_PATCHER_APPID."
exit()
