% This function creates toolbox documentation

function buildDoc

options = struct('outputDir','/toolbox/html','createThumbnail',false,'useNewFigure',false,'evalCode',false);

publish('matcompare',options)

end