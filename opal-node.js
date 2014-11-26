var fs, parser, parserFile, source, sourceFile, vm;

sourceFile = "" + __dirname + "/node_modules/opal/opal/opal.js";
parserFile = "" + __dirname + "/node_modules/opal/opal/opal-parser.js";

fs = require('fs');
vm = require('vm');

source = fs.readFileSync(sourceFile).toString();
parser = fs.readFileSync(parserFile).toString();

vm.runInThisContext(source, sourceFile);
vm.runInThisContext(parser, parserFile);

Opal.compile = function(ruby, options) {
  var compiler = this.Opal.Compiler.$new();
  var source = compiler.$compile(ruby);
  var out = "";
  var required = "";

  var requires = compiler.$requires();
  for (var i = 0; i < requires.length; i++) {
    try {
      required = fs.readFileSync("" + __dirname + "/node_modules/opal/opal/" + requires[i] + ".js").toString();
    } catch (e) {
      var required_source = fs.readFileSync("" + __dirname + "/js/opal/" + requires[i] + ".rb").toString();
      required = compiler.$compile(required_source);
    }
    out += required;
  }
  return out + source;
}

module.exports = Opal;
