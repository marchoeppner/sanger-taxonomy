//
// This file holds functions to validate user-supplied arguments
//

class WorkflowPipeline {

    //
    // Check and validate parameters
    //
    public static void initialise( params, log) {

        if (params.input) {
            if (!params.reference_base) {
                log.info "No reference_base set; check your settings/profile"
                System.exit(1)
            }
            if (!params.db) {
                log.info "Must provide a valid database name (--db)"
                System.exit(1)
            }
            if (!params.run_name) {
                log.info 'Must provide a run_name (--run_name)'
                System.exit(1)
            }
            
        }

        if (params.list_dbs) {
            println('Available databases:')
            println('===========================')
            params.references.databases.keySet().each { db ->
                def info = params.references.databases[db].description
                println("Name: ${db}\tSource: ${info}")
                println('---------------------------')
            }
            System.exit(1)
        }

        if (!params.input && !params.build_references) {
            log.info "Pipeline requires a sample sheet as input (--input)"
            System.exit(1)
        }
    }

}
