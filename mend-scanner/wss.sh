#!/bin/bash

set -x

verifySuccess() {
    scan="$GITHUB_SERVER_URL/$GITHUB_REPOSITORY/actions/runs/$GITHUB_RUN_ID"
    exitCode="$1"

    case "$exitCode" in
    0)
        echo "$scan completed successfully!"
        ;;
    255)
        error="A general error has occurred in $scan!"
        # ERROR: General error has occurred.
        ;;
    254)
        policyRejectionSummary=$(find ./whitesource -name 'policyRejectionSummary.json')
        totalRejected=$(jq '(.summary.totalRejectedLibraries)' "$policyRejectionSummary")
        error="$totalRejected Whitesource policy violation(s) found in $scan"
        error+=$'\n\n'
        error+=$(jq -r '.rejectingPolicies[] | .rejectedLibraries[] | "- Dependency \(.name) used in \(.manifestFile)\n"' "$policyRejectionSummary")
        error+=$'\n\n'
        error+="If there are any new violations, please create a ticket in JIRA to address the issue."
        error+=$'\n'
        error+="https://jira.trimble.tools/secure/CreateIssue!default.jspa"

        # POLICY_VIOLATION:
        # One or more of the scanned components violates an Organization or Product level policy.
        # Policy summary reports are created and saved in the newly-created whitesource directory,
        # located under the current working directory ($pwd or %cd%).
        # Only applicable when configured to checkPolicies=true and forceUpdate=false.
        ;;
    253)
        error="A client-side error has occurred in $scan!"
        # CLIENT_FAILURE: Client-side error has occurred.
        ;;
    252)
        error="The agent was unable to establish a connection to the WhiteSource application server in $scan!"
        # CONNECTION_FAILURE:
        # The agent was unable to establish a connection to the WhiteSource application server
        # (e.g., due to a blocked Internet connection).
        ;;
    251)
        error="A client-side error has occurred in $scan!"
        # SERVER_FAILURE: Server-side error has occurred
        # (e.g., a malformed request or a request that cannot be parsed was received).
        ;;
    250)
        error="One of the package manager's prerequisite steps has failed in $scan!"
        # PRE_STEP_FAILURE:
        # One of the package manager's prerequisite steps
        # (e.g., npm install, bower install, etc.) failed.
        ;;
    *)
        error "An error code ($exitCode) has occurred during $scan!"
        ;;
    esac

    if [ -n "$error" ]; then
        {
            echo 'ws_scan_error<<EOF' >>"$GITHUB_ENV"
            echo "$GITHUB_WORKFLOW: $error"
            echo 'EOF'
        } >> "$GITHUB_ENV"
    fi
}


if [ -z "$WS_API_KEY" ]; then
  echo "You must set an API key!"
  exit 126
fi

PROJECT_NAME_STR=""
if [ -z "$WS_PROJECT_NAME" ]; then
  PROJECT_NAME_STR=${GITHUB_REPOSITORY#*/}
else
  PROJECT_NAME_STR="$WS_PROJECT_NAME"
fi

if [ -z "$WS_CONFIG_FILE" ] && [ -z "$PROJECT_NAME_STR" ]; then
  echo "'projectName' or 'configFile' path must be set."
  exit 126
fi

PRODUCT_NAME_STR=""
if [ -n "$WS_PRODUCT_NAME" ]; then
  PRODUCT_NAME_STR="-product $WS_PRODUCT_NAME"
fi


# Download latest Unified Agent release from Whitesource
curl -LJO https://github.com/whitesource/unified-agent-distribution/releases/latest/download/wss-unified-agent.jar
jarSha256=$(curl -sL https://github.com/whitesource/unified-agent-distribution/releases/latest/download/wss-unified-agent.jar.sha256)
if [[ "$jarSha256" != "$(sha256sum wss-unified-agent.jar)" ]]; then
    echo "Agent integrity check failed"
    exit 1
fi


#unset GOROOT passed automatically by setup-go
unset GOROOT

# don't exit if unified agent exits with error code
set +e
# Execute Unified Agent (2 settings)
if [ -z  "$WS_CONFIG_FILE" ]; then
  java -jar wss-unified-agent.jar -noConfig true -apiKey "$WS_API_KEY" scanComment "$WS_SCSN_COMMENT" -project "$PROJECT_NAME_STR" "$PRODUCT_NAME_STR"\
    -d . -wss.url "$WS_WSS_URL" -resolveAllDependencies true
else
  java -jar wss-unified-agent.jar -apiKey "$WS_API_KEY" -c "$WS_CONFIG_FILE" -scanComment "$WS_SCAN_COMMENT"
fi
verifySuccess $?
