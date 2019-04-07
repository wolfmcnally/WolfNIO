#!/bin/bash

TEMPLATE_NAME="Wolf""Template" # Protect this string from being changed by the first `find/sed` below.
NEW_NAME=$1

# Change all template name strings in the hierarchy to the new name.
export LC_ALL=C
find . -type f -exec sed -i '' s/$TEMPLATE_NAME/$NEW_NAME/g {} +

# Change all directory names in the hierarchy to the new name.
find . -type d -name "*$TEMPLATE_NAME*" | sed -e "p;s/$TEMPLATE_NAME/$NEW_NAME/" | xargs -n2 mv

# Change all file names in the directory to the new name.
find . -type f -name "*$TEMPLATE_NAME*" | sed -e "p;s/$TEMPLATE_NAME/$NEW_NAME/" | xargs -n2 mv
