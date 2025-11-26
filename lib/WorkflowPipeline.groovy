//
// This file holds functions to validate user-supplied arguments
//

class WorkflowPipeline {

    //
    // Check and validate parameters
    //
    public static void initialise( params, log) {

         if (params.list_primers) {
            println('Pre-configured primer sets:')
            println('===========================')
            println('===========================')
            params.primers.keySet().each { primer ->
                def info = params.primers[primer].description
                def method = params.primers[primer].method
                def database = params.primers[primer].db
                println "Name: ${primer}\nMethod: ${method}\nDB: ${db}"
                println "---------------------------------------------"
            }
            System.exit(1)
        }
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
            if (params.primer_set && !params.primers.keySet().contains(params.primer_set)) {
                log.info "The primer set ${params.primer_set} is not currently configured."
                System.exit(1)
            }
            if (!params.primer_set && !params.primers_fa) {
                log.info 'No primer set (--primer_set) or custom primers (--primers_fa) provided. Exiting...'
                System.exit(1)
            }
            if (params.primers_fa && !params.db) {
                log.info 'Did not provide a database name (--db)'
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
