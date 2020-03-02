
from twisted.internet import defer, threads
from twisted.python import log

import fts.util
import fts.metadata_extractors
import json

class sbnd_extractor(fts.metadata_extractors.MetadataExtractorRunCommand):

    name="sbnd_extractor"

    @defer.inlineCallbacks
    def extract( self, filestate, *args, **kwargs):

        mddata = yield self._runCommand("/sbnd/app/users/sbndpro/soft/srcs/sbndutil/scripts/poms/sbndpoms_metadata_extractor.sh", filestate.getLocalFilePath())
        md = json.loads(mddata)

        # fix any metadata fields here
        # md['xxx'] = blah(md['yy']) or whatever

        defer.returnValue(md)
