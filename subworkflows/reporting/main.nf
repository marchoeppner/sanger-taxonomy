include { HELPER_REPORT_XLSX }              from './../../modules/helper/report_xlsx'
include { HELPER_REPORTS_JSON }             from './../../modules/helper/reports_json'

workflow REPORTING {

    take:
    ch_reports      // all sample level reports
    versions_yaml
    settings_json

    main:

    ch_xlsx         = Channel.from([])
    ch_versions     = Channel.from([])
    
    // The sample-level summary JSON
    HELPER_REPORTS_JSON(
        ch_reports.groupTuple(),
        versions_yaml.collect(),
        settings_json
    )

    // Excel report
    HELPER_REPORT_XLSX(
        HELPER_REPORTS_JSON.out.json.map {m,j -> j}.collect()
    )

    ch_xlsx = ch_xlsx.mix(HELPER_REPORT_XLSX.out.xlsx)


    emit:
    versions = ch_versions
    xlsx     = ch_xlsx
}
