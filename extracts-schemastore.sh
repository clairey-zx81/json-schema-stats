#! /bin/bash
#
# extraits intéressants pour un article
#

source extracts.sh

#
# BAD MIX
#

extract \
  "minLength badly placed: either minItems on array or minLength on the string item" \
  '.definitions.rules.properties."import-blacklist".definitions.options.items.oneOf[2]' \
  ../gits/schemastore/src/schemas/json/tslint.json

extract \
  "propertyNames on string ... should be one level above" \
  '.definitions.compatibilityInfo.additionalProperties' \
  ../gits/schemastore/src/schemas/json/azure-deviceupdate-manifest-definitions-4.0.json

extract \
  "propertyNames on string ... should be one level above" \
  '.definitions.fileHashes.additionalProperties' \
  ../gits/schemastore/src/schemas/json/azure-deviceupdate-manifest-definitions-4.0.json

extract \
  "propertyNames on string ... should be one level above" \
  '.definitions.compatibilityInfo.additionalProperties' \
  ../gits/schemastore/src/schemas/json/azure-deviceupdate-manifest-definitions-5.0.json

extract \
  "propertyNames on string ... should be one level above" \
  '.definitions.fileHashes.additionalProperties' \
  ../gits/schemastore/src/schemas/json/azure-deviceupdate-manifest-definitions-5.0.json

extract \
  "minLength badly placed: not on array" \
  '.definitions.notification.properties.events' \
  ../gits/schemastore/src/schemas/json/bamboo-spec.json

extract \
  "DOUBT: permission is recursive, but does not have a type, so anything is somehow possible:-/" \
  '.definitions.permission' \
  ../gits/schemastore/src/schemas/json/bukkit-plugin.json

extract \
  "minimum badly placed: not a string" \
  '.definitions.macosExecutor.properties.xcode' \
  ../gits/schemastore/src/schemas/json//circleciconfig.json

extract \
  "items on object ... should be on array" \
  '.definitions.openstackTypesProject.allOf[4].properties.tags' \
  ../gits/schemastore/src/schemas/json/cloudify.json

extract \
  "additionalProperties on array ... should be one level above" \
  '.definitions.cloudifyDatatypesHelmSetFlagsList' \
  ../gits/schemastore/src/schemas/json/cloudify.json

extract \
  "properties on array ... probably missing items with properties" \
  '.definitions.nodeTypeAWSEC2SecurityGroupRuleIngress.allOf[1].properties."resource_config".properties.IpPermissions.items.properties.IpRanges' \
  ../gits/schemastore/src/schemas/json/cloudify.json

extract \
  "properties and required on string ... probably on object" \
  '.definitions.cloudifyDatatypesAzureNetworkVirtualNetworkConfig' \
  ../gits/schemastore/src/schemas/json/cloudify.json

extract \
  "properties on string ... should be on object" \
  '.definitions.nodeTypeCloudifyAzureNodesComputeContainerServiceInterfaces.properties."cloudify.interfaces.lifecycle".properties.delete' \
  ../gits/schemastore/src/schemas/json/cloudify.json

extract \
  "minimum on array ... should be minItems" \
  '.definitions.update.properties.reviewers' \
  ../gits/schemastore/src/schemas/json//dependabot-2.0.json

extract \
  "minimum on array ... should be minItems" \
  '.definitions.update.properties.assignees' \
  ../gits/schemastore/src/schemas/json//dependabot-2.0.json

extract \
  "minItems on object ... should be minProperties" \
  '.properties.update_configs.items.properties.ignored_updates.items' \
  ../gits/schemastore/src/schemas/json/dependabot.json

extract \
  "minItems on object ... should be minProperties" \
  '.properties.update_configs.items.properties.automerged_updates.items' \
  ../gits/schemastore/src/schemas/json/dependabot.json

extract \
  "minItems on object ... should be minProperties" \
  '.properties.update_configs.items.properties.allowed_updates.items' \
  ../gits/schemastore/src/schemas/json/dependabot.json

extract \
  "items on string ... should be on array" \
  '.properties.update_configs.items.properties.target_branch' \
  ../gits/schemastore/src/schemas/json/dependabot.json

extract \
  "minLength on array ... should be minItems" \
  '.definitions.kind_pipeline.properties.steps' \
  ../gits/schemastore/src/schemas/json/drone.json

extract \
  "uniqueItems on object ... should be one level above" \
  '.properties."linters-settings".properties.depguard.properties."packages-with-error-message"' \
  ../gits/schemastore/src/schemas/json/golangci-lint.json

extract \
  "additionalProperties on array ... should be probably additionalItems" \
  '.definitions."version-2".properties.watchFiles' \
  ../gits/schemastore/src/schemas/json/host.json

extract \
  "required on string ... should be on object" \
  .properties.body.properties.style.properties.border.oneOf[0] \
  ../gits/schemastore/src/schemas/json/jasonette.json

extract \
  "required on string ... should be on object" \
  .properties.body.properties.style.properties.border.oneOf[1] \
  ../gits/schemastore/src/schemas/json/jasonette.json
  
extract \
  "additionalItems on object ... should be on array" \
  . \
  ../gits/schemastore/src/schemas/json/jdt.json

extract \
  "additionalProperties on array ... should be probably additionalItems" \
  '.definitions.stepTypes.Matrix.properties.stepletMultipliers.properties.allowFailures' \
  ../gits/schemastore/src/schemas/json/jfrog-pipelines.json

extract \
  "additionalProperties on array ... should be probably additionalItems" \
  '.definitions.stepTypes.Matrix.properties.stepletMultipliers.properties.exclude' \
  ../gits/schemastore/src/schemas/json/jfrog-pipelines.json

extract \
  "additionalProperties on array ... should be probably additionalItems" \
  '.definitions.stepTypes.Matrix.properties.stepletMultipliers.properties.environmentVariables' \
  ../gits/schemastore/src/schemas/json/jfrog-pipelines.json

extract \
  "additionalProperties on array ... should be probably additionalItems" \
  '.definitions.stepTypes.Matrix.properties.stepletMultipliers.properties.runtimes' \
  ../gits/schemastore/src/schemas/json/jfrog-pipelines.json

extract \
  "additionalProperties on boolean ... grrr" \
  '.definitions.stepTypes.Matrix.properties.stepletMultipliers.properties.fastFail' \
  ../gits/schemastore/src/schemas/json/jfrog-pipelines.json 

extract \
  "additionalProperties on array ... should be probably additionalItems" \
  '.properties.places' \
  ../gits/schemastore/src/schemas/json/ninjs-2.0.json

extract \
  "additionalProperties on array ... should be probably additionalItems" \
  '.properties.renditions' \
  ../gits/schemastore/src/schemas/json/ninjs-2.0.json

extract \
  "additionalProperties on array ... should be probably additionalItems" \
  '.properties.associations' \
  ../gits/schemastore/src/schemas/json/ninjs-2.0.json

extract \
  "additionalProperties on string ... grrr" \
  '.properties.rightsinfo.properties.encodedrights' \
  ../gits/schemastore/src/schemas/json/ninjs-2.0.json

extract \
  "pattern on array ... should be on string" \
  '.properties.softdepend.anyOf[0]' \
  ../gits/schemastore/src/schemas/json/pocketmine-plugin.json

extract \
  "properties on array ... probably missing items with properties" \
  '."$defs"."r2c-internal-project-depends-on-content".properties' \
  ../gits/schemastore/src/schemas/json/semgrep.json

extract \
  "uniqueItems on string ... should be one level above" \
  '.properties.postActions.items.allOf[1].oneOf[6].properties.args.properties.projectFiles.oneOf[0].items' \
  ../gits/schemastore/src/schemas/json/template.json

extract \
  "uniqueItems on string ... should be one level above" \
  '.properties.symbols.additionalProperties.oneOf[3].properties.forms.properties.global.oneOf[0].items' \
  ../gits/schemastore/src/schemas/json/template.json

extract \
  "uniqueItems on string ... should be one level above" \
  '.properties.postActions.items.allOf[1].oneOf[5].properties.args.properties.files.oneOf[0].items' \
  ../gits/schemastore/src/schemas/json/template.json

extract \
  "uniqueItems on string ... should be one level above" \
  '.properties.postActions.items.allOf[1].oneOf[4].properties.args.additionalProperties.oneOf[0].items' \
  ../gits/schemastore/src/schemas/json/template.json

extract \
  "uniqueItems on string ... should be one level above" \
  '.properties.postActions.items.allOf[1].oneOf[3].properties.args.properties.targetFiles.oneOf[0].items' \
  ../gits/schemastore/src/schemas/json/template.json

extract \
  "minItems, maxItems on string ... should be one level above" \
  '.definitions.rules.properties.curly.definitions.options' \
  ../gits/schemastore/src/schemas/json/tslint.json

extract \
  "minItems, maxItems on string ... should be one level above" \
  '.definitions.rules.properties.whitespace.definitions.options.items' \
  ../gits/schemastore/src/schemas/json/tslint.json

extract \
  "minItems, maxItems on string ... should be one level above" \
  '.definitions.rules.properties."comment-format".definitions.options.items.anyOf[0]' \
  ../gits/schemastore/src/schemas/json/tslint.json

extract \
  "minLength on array ... should be probably minItems" \
  '.definitions.rules.properties."max-line-length".definitions.options' \
  ../gits/schemastore/src/schemas/json/tslint.json

extract \
  "minLength on array ... should be probably minItems" \
  '.definitions.rules.properties."no-unnecessary-class".definitions.options' \
  ../gits/schemastore/src/schemas/json/tslint.json

extract \
  "minItems on object ... should be probably minProperties" \
  '.definitions.localeMap' \
  ../gits/schemastore/src/schemas/json/typo3.json 

extract \
  "items on object ... probably missing properties" \
  '.properties.experiment_apis' \
  ../gits/schemastore/src/schemas/json/webextension.json

extract \
  "additionalProperties on array ... should be probably additionalItems" \
  '.properties.errorPage' \
  ../gits/schemastore/src/schemas/json/xs-app.json

#
# MISSING TYPE
#

extract \
  "textBinding could not be an object" \
  '.definitions.textBinding' \
  ../gits/schemastore/src/schemas/json/band-manifest.json

extract \
  "page could not be an object" \
  '.definitions.page' \
  ../gits/schemastore/src/schemas/json/band-manifest.json

#
# ERROR TYPOS
#
# schemastore: 11 on 469 schemas

# Also:
# ../gits/schemastore/src/schemas/json//fly.json
# ../gits/schemastore/src/schemas/json//replit.json
# ../gits/schemastore/src/schemas/json//rust-toolchain.json
# ../gits/schemastore/src/schemas/json//rustfmt.json
# ../gits/schemastore/src/schemas/json//dein.json

extract \
  "Extension x-taplo with keywords looking like JSON schema" \
  '."x-taplo-info"' \
  ../gits/schemastore/src/schemas/json//cargo-make.json

extract \
  "typeof: extension used in some schemas" \
  ".definitions.WindowsConfiguration.properties.sign" \
  ../gits/schemastore/src/schemas/json//electron-builder.json

extract \
  "numItems -> maxItems or minItems ... used several times" \
  ".defs.scale.allOf[1].oneOf[0].properties.range.oneOf[3].properties.extent.oneOf[0]" \
  ../gits/schemastore/src/schemas/json//vega.json

extract \
  "min -> minimum with number" \
  '.definitions.rules.properties."space-within-parens".definitions.options.items' \
  ../gits/schemastore/src/schemas/json//tslint.json

#
# BAD PROPERTIES NESTING
#

extract \
  "additionalProperties should be one level above" \
  '.properties.security.properties.exec.properties' \
  ../gits/schemastore/src/schemas/json/hugo.json
