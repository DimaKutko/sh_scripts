#!/bin/zsh

# Check if the module name is passed in
if [ -z "$1" ]; then
  echo "Please specify the name of the module"
  exit 1
fi

# Get the module name
MODULE_NAME=$1

# Get the package name from pubspec.yaml
if [ -f "pubspec.yaml" ]; then
  PACKAGE_NAME=$(grep -E '^name:' pubspec.yaml | awk '{print $2}')
else
  echo "Файл pubspec.yaml не найден в текущем каталоге."
  exit 1
fi

# Convert the module name to PascalCase (capitalize each word without underscores)
MODULE_CLASS_NAME=$(echo "$MODULE_NAME" | awk -F'_' '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1' OFS='')

# Define the base path for creating folders
BASE_PATH="lib/modules/$MODULE_NAME"
CUBIT_PATH="$BASE_PATH/cubit"
VIEW_PATH="$BASE_PATH/view"

# Create the necessary folders
mkdir -p "$CUBIT_PATH" "$VIEW_PATH"

# Create and populate the file for Module State
cat <<EOL > "$CUBIT_PATH/${MODULE_NAME}_state.dart"
part of '${MODULE_NAME}_cubit.dart';

class ${MODULE_CLASS_NAME}State extends BaseState {
  const ${MODULE_CLASS_NAME}State();
}
EOL

# Create and populate the file for Module Cubit with updated imports
cat <<EOL > "$CUBIT_PATH/${MODULE_NAME}_cubit.dart"
import 'package:$PACKAGE_NAME/modules/common/cubit/base_cubit.dart';

part '${MODULE_NAME}_state.dart';

class ${MODULE_CLASS_NAME}Cubit extends BaseCubit<${MODULE_CLASS_NAME}State> {
   ${MODULE_CLASS_NAME}Cubit() : super(const ${MODULE_CLASS_NAME}State());
}
EOL

# Create and populate the file for Module Layout with updated imports
cat <<EOL > "$VIEW_PATH/${MODULE_NAME}_layout.dart"
import 'package:flutter/material.dart';
import 'package:$PACKAGE_NAME/modules/common/view/base_layout.dart';
import 'package:$PACKAGE_NAME/modules/$MODULE_NAME/cubit/${MODULE_NAME}_cubit.dart';

class ${MODULE_CLASS_NAME}Layout extends BaseLayout {
  const ${MODULE_CLASS_NAME}Layout({super.key});

  @override
  State<StatefulWidget> createState() => _${MODULE_CLASS_NAME}LayoutState();
}

class _${MODULE_CLASS_NAME}LayoutState extends BaseLayoutState<${MODULE_CLASS_NAME}State, ${MODULE_CLASS_NAME}Cubit, ${MODULE_CLASS_NAME}Layout> {
  @override
  Widget buildLayout(BuildContext context) {
    return const Center(
      child: Text('${MODULE_CLASS_NAME} Layout'),
    );
  }
}
EOL

# Create and populate a file for Module Screen with updated imports
cat <<EOL > "$VIEW_PATH/${MODULE_NAME}_screen.dart"
import 'package:auto_route/auto_route.dart';
import 'package:$PACKAGE_NAME/modules/common/view/base_screen.dart';
import 'package:$PACKAGE_NAME/modules/$MODULE_NAME/cubit/${MODULE_NAME}_cubit.dart';
import 'package:$PACKAGE_NAME/modules/$MODULE_NAME/view/${MODULE_NAME}_layout.dart';

@RoutePage()
class ${MODULE_CLASS_NAME}Screen extends BaseScreen<${MODULE_CLASS_NAME}State, ${MODULE_CLASS_NAME}Cubit, ${MODULE_CLASS_NAME}Layout> {
  const ${MODULE_CLASS_NAME}Screen({super.key});

  static const routeName = '/${MODULE_NAME}';

  @override
  ${MODULE_CLASS_NAME}Cubit get cubit => ${MODULE_CLASS_NAME}Cubit();

  @override
  ${MODULE_CLASS_NAME}Layout get layout => const ${MODULE_CLASS_NAME}Layout();
}
EOL

echo "Module $MODULE_NAME was successfully created!"