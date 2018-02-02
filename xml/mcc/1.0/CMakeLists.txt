FILE(GLOB xml_files *.xml)
install(FILES ${xml_files} DESTINATION ${product}/${version}/xml/mcc/1.0)
install_source( EXTRAS ${xml_files} )
