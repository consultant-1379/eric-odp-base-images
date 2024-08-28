#!/usr/bin/env groovy

def bob = "./bob/bob"
def ruleset = "ci/local_ruleset.yaml"
def ci_ruleset = "ci/common_ruleset2.0.yaml"

try {
    stage('Custom Images Package') {
    	if (env.RELEASE) {
            sh "${bob} -r ${ruleset} image:docker-push-all-images-release"
        }else{
            sh "${bob} -r ${ruleset} image:docker-push-all-images-internal"
        }
    }
} catch (e) {
    throw e
} finally {
    archiveArtifacts allowEmptyArchive: true, artifacts: '**/*bth-linter-output.html, **/design-rule-check-report.*'
}
