lua << EOF
package.loaded["misirlou.palette"] = nil
require("misirlou-git").colorscheme()
EOF

