#!groovy
import groovy.json.JsonOutput
import groovy.json.JsonSlurper

withCredentials([string(credentialsId: 'SLACK_WEBHOOK_KEY', variable: 'SLACK_WEBHOOK_KEY')]) {
    slackApiKey = env.SLACK_WEBHOOK_KEY
}

projectName = "demo"
workingDir = "demo/"
slackChannel = "terraform"
authorizedSubmitter = "admin,jenkinsuser"
buildNumber = env.BUILD_NUMBER

apply = false

node('ubuntu') {
    checkout()
    plan()
    if (apply == true) {
        applyPlan()
    }
}


def checkout() {
    stage('Pull'){
        checkout poll: false, scm: [$class: 'GitSCM', branches: [[name: '*/master']],
        doGenerateSubmoduleConfigurations: false, extensions: [[$class: 'SparseCheckoutPaths',
        sparseCheckoutPaths: [[path: "${projectName}"]]]], submoduleCfg: [],
        userRemoteConfigs: [[credentialsId: 'someid', url: 'git@github.com:bry5an/terraform.git']]]
    dir("${workingDir}") {
        if (fileExists("status.apply")) {
            sh "rm status.apply"
            }
        if (fileExists("status")) {
            sh 'rm status'
            }
        if (fileExists("show")) {
            sh "rm show"
            }
        if (fileExists("plan.out")) {
            sh "rm plan.out"
            }
        }
    }
}

def plan() {
    stage('Plan'){
      wrap([$class: 'BuildUser']) { // https://wiki.jenkins-ci.org/display/JENKINS/Build+User+Vars+Plugin variables available inside this block
        dir("${workingDir}") {
            ansiColor('xterm') {
            sh 'terraform init'
            sh 'terraform get -update'
            sh 'set +e; terraform plan -out=plan.out -detailed-exitcode; echo $? > status'
            }
            def exitCode = readFile('status').trim()
                echo "Terraform Plan Exit Code: ${exitCode}"
                if (exitCode == "0") {
                    slackMessage("Plan - No changes pending:  <${env.JOB_URL}|${projectName}> - (started by ${BUILD_USER_FIRST_NAME})", "good", slackApiKey)
                    currentBuild.result = 'SUCCESS'
                }
                if (exitCode == "1") {
                    slackMessage("Plan Failed: <${env.JOB_URL}|${projectName}> - (started by ${BUILD_USER_FIRST_NAME})", "danger", slackApiKey)
                    currentBuild.result = 'FAILURE'
                }
                if (exitCode == "2") {
                    slackMessage("Plan Awaiting Approval: <${env.JOB_URL}|${projectName}> - (started by ${BUILD_USER_FIRST_NAME})", "good", slackApiKey)
                    try {
                        feedback = input(submitterParameter: 'submitter', message: 'Apply Plan?', ok: 'Apply', submitter: "${authorizedSubmitter}")
                        apply = true

                    } catch (err) {
                        slackMessage("Plan Discarded: <${env.JOB_URL}|${projectName}>", "warning", slackApiKey)
                        apply = false
                        currentBuild.result = 'UNSTABLE'
                    }
                }
            }
          }
        }
    }

def applyPlan() {
    stage('Apply'){
        dir("${workingDir}") {
            sh 'set +e; terraform apply plan.out; echo $? > status.apply'
            def applyExitCode = readFile('status.apply').trim()
            if (applyExitCode == "0") {
                slackMessage("Build #${env.BUILD_NUMBER} - Changes Applied: <${env.JOB_URL}|${projectName}>", "good", slackApiKey)
            } else {
                slackMessage("Build #${env.BUILD_NUMBER} - Apply Failed <${env.JOB_URL}|${projectName}>", "danger", slackApiKey)
                currentBuild.result = 'FAILURE'
            }
        }
    }
}


def slackMessage(message, color, slackApiKey) {
    slackSend channel: slackChannel, color: color, failOnError: true, message: message, teamDomain: 'yourteam', token: slackApiKey
}
