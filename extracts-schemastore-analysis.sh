#! /bin/bash
#
# extraits intéressants pour un article
#

source extracts.sh

#
# BAD MIX
#

extract \
  "minLength on array ... grrr" \
  ".definitions.job_template.properties.artifacts.properties.paths" \
  ../YAC/corpus/Store/schemastore-analysis/JSON/Gitlab_CI_configuration.json

extract \
  "minLength on array ... grrr" \
  ".definitions.job_template.properties.artifacts.properties.reports.properties.junit.oneOf[1]" \
  ../YAC/corpus/Store/schemastore-analysis/JSON/Gitlab_CI_configuration.json

extract \
  "uniqueItems on object ... should be one level above" \
  ".definitions.ice.anyOf[0]" \
  ../YAC/corpus/Store/schemastore-analysis/JSON/JSON_schema_.NET_template_files.json

extract \
  "uniqueItems on object ... should be one level above" \
  ".definitions.compilationOptions.properties.define" \
  ../YAC/corpus/Store/schemastore-analysis/JSON/JSON_schema_for_.NET_Core_project.json_files.json

extract \
  "uniqueItems on object ... should be one level above" \
  ".definitions.compilationOptions.properties.nowarn" \
  ../YAC/corpus/Store/schemastore-analysis/JSON/JSON_schema_for_.NET_Core_project.json_files.json

extract \
  "uniqueItems on object ... should be one level above" \
  ".definitions.packOptions.properties.owners" \
  ../YAC/corpus/Store/schemastore-analysis/JSON/JSON_schema_for_.NET_Core_project.json_files.json

extract \
  "uniqueItems on object ... should be one level above" \
  ".definitions.packOptions.properties.tags" \
  ../YAC/corpus/Store/schemastore-analysis/JSON/JSON_schema_for_.NET_Core_project.json_files.json

extract \
  "uniqueItems on object ... should be one level above" \
  ".properties.authors" \
  ../YAC/corpus/Store/schemastore-analysis/JSON/JSON_schema_for_.NET_Core_project.json_files.json

extract \
  "uniqueItems on object ... should be one level above" \
  ".properties.tags" \
  ../YAC/corpus/Store/schemastore-analysis/JSON/JSON_schema_for_.NET_Core_project.json_files.json

extract \
  "uniqueItems on object ... should be one level above" \
  ".properties.owners" \
  ../YAC/corpus/Store/schemastore-analysis/JSON/JSON_schema_for_.NET_Core_project.json_files.json

extract \
  "uniqueItems on object ... should be one level above" \
  ".definitions.buildOptions.properties.define" \
  ../YAC/corpus/Store/schemastore-analysis/JSON/JSON_schema_for_.NET_Core_project.json_files.json

extract \
  "uniqueItems on object ... should be one level above" \
  ".definitions.buildOptions.properties.nowarn" \
  ../YAC/corpus/Store/schemastore-analysis/JSON/JSON_schema_for_.NET_Core_project.json_files.json

extract \
  "uniqueItems on object ... should be one level above" \
  ".definitions.buildOptions.properties.nowarn" \
  ../YAC/corpus/Store/schemastore-analysis/JSON/JSON_schema_for_.NET_Core_project.json_files_1.json

extract \
  "uniqueItems on object ... should be one level above" \
  ".definitions.compilationOptions.properties.define" \
  ../YAC/corpus/Store/schemastore-analysis/JSON/JSON_schema_for_.NET_Core_project.json_files_1.json

extract \
  "uniqueItems on object ... should be one level above" \
  ".definitions.buildOptions.properties.define" \
  ../YAC/corpus/Store/schemastore-analysis/JSON/JSON_schema_for_.NET_Core_project.json_files_1.json

extract \
  "uniqueItems on object ... should be one level above" \
  ".properties.tags" \
  ../YAC/corpus/Store/schemastore-analysis/JSON/JSON_schema_for_.NET_Core_project.json_files_1.json

extract \
  "uniqueItems on object ... should be one level above" \
  ".definitions.compilationOptions.properties.nowarn" \
  ../YAC/corpus/Store/schemastore-analysis/JSON/JSON_schema_for_.NET_Core_project.json_files_1.json

extract \
  "uniqueItems on object ... should be one level above" \
  ".definitions.buildOptions.properties.nowarn" \
  ../YAC/corpus/Store/schemastore-analysis/JSON/JSON_schema_for_.NET_Core_project.json_files_1.json

extract \
  "uniqueItems on object ... should be one level above" \
  ".properties.owners" \
  ../YAC/corpus/Store/schemastore-analysis/JSON/JSON_schema_for_.NET_Core_project.json_files_1.json

extract \
  "uniqueItems on object ... should be one level above" \
  ".properties.authors" \
  ../YAC/corpus/Store/schemastore-analysis/JSON/JSON_schema_for_.NET_Core_project.json_files_1.json

extract \
  "uniqueItems on object ... should be one level above" \
  ".definitions.packOptions.properties.tags" \
  ../YAC/corpus/Store/schemastore-analysis/JSON/JSON_schema_for_.NET_Core_project.json_files_1.json

extract \
  "uniqueItems on object ... should be one level above" \
  ".definitions.compilationOptions.properties.define" \
  ../YAC/corpus/Store/schemastore-analysis/JSON/JSON_schema_for_ASP.NET_project.json_files.json

extract \
  "uniqueItems on object ... should be one level above" \
  ".properties.authors" \
  ../YAC/corpus/Store/schemastore-analysis/JSON/JSON_schema_for_ASP.NET_project.json_files.json

extract \
  "uniqueItems on object ... should be one level above" \
  ".properties.authors" \
  ../YAC/corpus/Store/schemastore-analysis/JSON/JSON_schema_for_ASP.NET_project.json_files_1.json

extract \
  "uniqueItems on object ... should be one level above" \
  ".definitions.compilationOptions.properties.define" \
  ../YAC/corpus/Store/schemastore-analysis/JSON/JSON_schema_for_ASP.NET_project.json_files_1.json

extract \
  "uniqueItems on object ... should be one level above" \
  ".properties.owners" \
  ../YAC/corpus/Store/schemastore-analysis/JSON/JSON_schema_for_ASP.NET_project.json_files_1.json

extract \
  "uniqueItems on object ... should be one level above" \
  ".properties.tags" \
  ../YAC/corpus/Store/schemastore-analysis/JSON/JSON_schema_for_ASP.NET_project.json_files_1.json

extract \
  "uniqueItems on object ... should be one level above" \
  ".definitions.compilationOptions.properties.define" \
  ../YAC/corpus/Store/schemastore-analysis/JSON/JSON_schema_for_ASP.NET_project.json_files_2.json

extract \
  "uniqueItems on object ... should be one level above" \
  ".properties.tags" \
  ../YAC/corpus/Store/schemastore-analysis/JSON/JSON_schema_for_ASP.NET_project.json_files_2.json

extract \
  "uniqueItems on object ... should be one level above" \
  ".properties.owners" \
  ../YAC/corpus/Store/schemastore-analysis/JSON/JSON_schema_for_ASP.NET_project.json_files_2.json

extract \
  "uniqueItems on object ... should be one level above" \
  ".properties.authors" \
  ../YAC/corpus/Store/schemastore-analysis/JSON/JSON_schema_for_ASP.NET_project.json_files_2.json

extract \
  "uniqueItems on object ... should be one level above" \
  ".definitions.compilationOptions.properties.define" \
  ../YAC/corpus/Store/schemastore-analysis/JSON/JSON_schema_for_ASP.NET_project.json_files_3.json

extract \
  "uniqueItems on object ... should be one level above" \
  ".properties.tags" \
  ../YAC/corpus/Store/schemastore-analysis/JSON/JSON_schema_for_ASP.NET_project.json_files_3.json

extract \
  "uniqueItems on object ... should be one level above" \
  ".properties.owners" \
  ../YAC/corpus/Store/schemastore-analysis/JSON/JSON_schema_for_ASP.NET_project.json_files_3.json

extract \
  "uniqueItems on object ... should be one level above" \
  ".properties.authors" \
  ../YAC/corpus/Store/schemastore-analysis/JSON/JSON_schema_for_ASP.NET_project.json_files_3.json

extract \
  "uniqueItems on object ... should be one level above" \
  ".definitions.watchDirectories" \
  ../YAC/corpus/Store/schemastore-analysis/JSON/JSON_schema_for_Azure_Functions_host.json_files.json

extract \
  "uniqueItems on object ... should be one level above" \
  ".definitions.functions" \
  ../YAC/corpus/Store/schemastore-analysis/JSON/JSON_schema_for_Azure_Functions_host.json_files.json

extract \
  "items on boolean or object ... impossible" \
  ".definitions.permission.properties.children.additionalProperties" \
  ../YAC/corpus/Store/schemastore-analysis/JSON/JSON_schema_for_Bukkit_Plugin_YAML.json

extract \
  "uniqueItems on object ... should be one level above" \
  ".properties.tags" \
  ../YAC/corpus/Store/schemastore-analysis/JSON/JSON_schema_for_DNX_project.json_files.json

extract \
  "uniqueItems on object ... should be one level above" \
  ".properties.authors" \
  ../YAC/corpus/Store/schemastore-analysis/JSON/JSON_schema_for_DNX_project.json_files.json

extract \
  "uniqueItems on object ... should be one level above" \
  ".properties.owners" \
  ../YAC/corpus/Store/schemastore-analysis/JSON/JSON_schema_for_DNX_project.json_files.json

extract \
  "uniqueItems on object ... should be one level above" \
  ".definitions.compilationOptions.properties.define" \
  ../YAC/corpus/Store/schemastore-analysis/JSON/JSON_schema_for_DNX_project.json_files.json

extract \
  "uniqueItems on object ... should be one level above" \
  ".definitions.compilationOptions.properties.define" \
  ../YAC/corpus/Store/schemastore-analysis/JSON/JSON_schema_for_DNX_project.json_files_1.json

extract \
  "uniqueItems on object ... should be one level above" \
  ".properties.tags" \
  ../YAC/corpus/Store/schemastore-analysis/JSON/JSON_schema_for_DNX_project.json_files_1.json

extract \
  "uniqueItems on object ... should be one level above" \
  ".properties.owners" \
  ../YAC/corpus/Store/schemastore-analysis/JSON/JSON_schema_for_DNX_project.json_files_1.json

extract \
  "uniqueItems on object ... should be one level above" \
  ".properties.authors" \
  ../YAC/corpus/Store/schemastore-analysis/JSON/JSON_schema_for_DNX_project.json_files_1.json

extract \
  "minLength on array ... should be minItems" \
  ".properties.overrides.items.properties.files.oneOf[1]" \
  ../YAC/corpus/Store/schemastore-analysis/JSON/JSON_schema_for_ESLint_configuration_files.json

extract \
  "items on string ... grrr" \
  ".properties.startup_app.properties.permissions.items" \
  ../YAC/corpus/Store/schemastore-analysis/JSON/JSON_schema_for_OpenFin_application_configuration_files.json

extract \
  "items on boolean ... grrr" \
  ".properties.disableAuth" \
  ../YAC/corpus/Store/schemastore-analysis/JSON/JSON_schema_for_Prisma_prisma.yml_files.json

extract \
  "items on boolean ... grrr" \
  ".properties.endpoint" \
  ../YAC/corpus/Store/schemastore-analysis/JSON/JSON_schema_for_Prisma_prisma.yml_files.json

extract \
  "items on boolean ... grrr" \
  ".properties.secret" \
  ../YAC/corpus/Store/schemastore-analysis/JSON/JSON_schema_for_Prisma_prisma.yml_files.json

extract \
  "minLength on object ... should be minProperties" \
  ".properties.schemas.items" \
  ../YAC/corpus/Store/schemastore-analysis/JSON/JSON_schema_for_SchemaStore.org_catalog_files.json

extract \
  "uniqueItems on object ... should be additionalProperties" \
  '.definitions.rules.properties.whitespace.definitions.options.items' \
  ../YAC/corpus/Store/schemastore-analysis/JSON/JSON_schema_for_UI5_manifest.json_project_declaration.json

extract \
  "properties on array ... should be type object" \
  '.properties."sap.ui5".properties.resources.additionalProperties' \
  ../YAC/corpus/Store/schemastore-analysis/JSON/JSON_schema_for_UI5_manifest.json_project_declaration.json

extract \
  "minItems, maxItems and uniqueItems should be one level above" \
  '.definitions.rules.properties.curly.definitions.options' \
  ../YAC/corpus/Store/schemastore-analysis/JSON/JSON_schema_for_the_TSLint_configuration_files..json

extract \
  "minItems, maxItems and uniqueItems should be one level above" \
  '.definitions.rules.properties."comment-format".definitions.options.items.anyOf[0]' \
  ../YAC/corpus/Store/schemastore-analysis/JSON/JSON_schema_for_the_TSLint_configuration_files..json

extract \
  "minItems, maxItems and uniqueItems should be one level above" \
  '.definitions.rules.properties.whitespace.definitions.options.items' \
  ../YAC/corpus/Store/schemastore-analysis/JSON/JSON_schema_for_the_TSLint_configuration_files..json

extract \
  "minLength, maxLength and uniqueItems should be one level above" \
  '.definitions.rules.properties."max-line-length".definitions.options' \
  ../YAC/corpus/Store/schemastore-analysis/JSON/JSON_schema_for_the_TSLint_configuration_files..json

extract \
  "maxLength and minLength should be one level above" \
  '.definitions.rules.properties."no-unnecessary-class".definitions.options' \
  ../YAC/corpus/Store/schemastore-analysis/JSON/JSON_schema_for_the_TSLint_configuration_files..json

extract \
  "uniqueItems should be one level above" \
  ".properties.settings.properties.namingRules.properties.allowedHungarianPrefixes.items" \
  ../YAC/corpus/Store/schemastore-analysis/JSON/StyleCop_Analyzers_Configuration.json

#
# ERROR TYPOS
#

extract \
  "minSize -> minItems with array" \
  ".definitions.groupStep.properties.steps" \
  ../YAC/corpus/Store/schemastore-analysis/JSON/JSON_schema_for_Buildkite_pipeline_configuration_files.json

extract \
  "ref -> \$ref" \
  ".definitions.commandStep.properties.commands" \
  ../YAC/corpus/Store/schemastore-analysis/JSON/JSON_schema_for_Buildkite_pipeline_configuration_files.json

extract \
  "ref -> \$ref" \
  '.definitions.possibleErrors.properties."no-unsafe-finally"' \
  ../YAC/corpus/Store/schemastore-analysis/JSON/JSON_schema_for_ESLint_configuration_files.json

extract \
  "min -> minimum with number" \
  '.definitions.rules.properties."space-within-parens".definitions.options.items' \
  ../YAC/corpus/Store/schemastore-analysis/JSON/JSON_schema_for_the_TSLint_configuration_files..json

extract \
  "schema -> \$schema" \
  ".schema" \
  ../YAC/corpus/Store/schemastore-analysis/JSON/Unity_Assembly_Definition.json
