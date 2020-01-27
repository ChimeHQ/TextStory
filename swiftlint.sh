#!/bin/sh

#  swiftlint.sh
#  Edit
#
#  Created by Matt Massicotte on 2019-12-23.
#  Copyright © 2019 Chime Systems. All rights reserved.

set -euxo pipefail

if which swiftlint >/dev/null; then
  swiftlint
else
  echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
fi
