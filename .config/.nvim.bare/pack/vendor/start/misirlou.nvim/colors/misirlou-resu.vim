lua << EOF
package.loaded["misirlou.palette"] = nil
require("misirlou-resu").colorscheme()
EOF
