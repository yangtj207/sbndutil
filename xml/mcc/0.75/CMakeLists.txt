FILE(GLOB xml_files *.xml)
install(FILES ${xml_files} DESTINATION xml/mcc/0.75)
install_source( EXTRAS ${xml_files} )
