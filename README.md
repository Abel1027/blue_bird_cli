<p align="center">
<img src="https://github.com/Abel1027/blue_bird_cli/raw/develop/blue_bird_cli_logo.svg" alt="Blue Bird CLI" height=300/>
</p>

![coverage][coverage_badge]
[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![License: MIT][license_badge]][license_link]

---

A Command-Line Interface for generating complex large-scale Flutter project and package architectures.

Generated by the [Very Good CLI][very_good_cli_link] 🤖

We encourage the VGV team to make accesible the Flutter and Dart CLIs from the **very good cli** package so we can extend those classes and add new features instead of repeating part of their code.

Thanks to VGV for the inspiration and the work that made possible the creation of the Blue Bird CLI 👍.

---

## Getting Started 🚀

### Installing

```sh
dart pub global activate blue_bird_cli
```

## Usage

```sh
# Show CLI version
$ blue_bird --version

# Show usage help
$ blue_bird --help
```

### `create` command

The following command create a Flutter project with a more complex architecture ideally for large Flutter apps.

```sh
# Create a new Flutter project named my_project
blue_bird create my_project
```

The stucture of the new project will be the following:

📦my_project  
 ┣ 📂android  
 ┣ 📂core  
 ┃ ┣ 📂components  
 ┃ ┃ ┣ 📂lib  
 ┃ ┃ ┃ ┣ 📂src  
 ┃ ┃ ┃ ┃ ┣ 📂config  
 ┃ ┃ ┃ ┃ ┃ ┗ 📜components_config.dart  
 ┃ ┃ ┃ ┃ ┗ 📂presentation  
 ┃ ┃ ┃ ┃ ┃ ┗ 📜components_example_widget.dart  
 ┃ ┃ ┃ ┗ 📜components.dart  
 ┃ ┃ ┣ 📂test  
 ┃ ┃ ┃ ┗ 📂src  
 ┃ ┃ ┃ ┃ ┗ 📜my_project_test.dart  
 ┃ ┃ ┣ 📜analysis_options.yaml  
 ┃ ┃ ┗ 📜pubspec.yaml  
 ┃ ┣ 📂dependencies  
 ┃ ┃ ┣ 📂lib  
 ┃ ┃ ┃ ┗ 📜dependencies.dart  
 ┃ ┃ ┣ 📜analysis_options.yaml  
 ┃ ┃ ┗ 📜pubspec.yaml  
 ┃ ┣ 📂di  
 ┃ ┃ ┣ 📂lib  
 ┃ ┃ ┃ ┣ 📂src  
 ┃ ┃ ┃ ┃ ┗ 📜di_injection_module.dart  
 ┃ ┃ ┃ ┗ 📜di.dart  
 ┃ ┃ ┣ 📜analysis_options.yaml  
 ┃ ┃ ┗ 📜pubspec.yaml  
 ┃ ┣ 📂internationalization  
 ┃ ┃ ┣ 📂lib  
 ┃ ┃ ┃ ┣ 📂src  
 ┃ ┃ ┃ ┃ ┗ 📂l10n  
 ┃ ┃ ┃ ┃ ┃ ┗ 📜intl_en.arb  
 ┃ ┃ ┃ ┗ 📜internationalization.dart  
 ┃ ┃ ┣ 📜analysis_options.yaml  
 ┃ ┃ ┣ 📜l10n.yaml  
 ┃ ┃ ┗ 📜pubspec.yaml  
 ┃ ┣ 📂network  
 ┃ ┃ ┣ 📂lib  
 ┃ ┃ ┃ ┗ 📜network.dart  
 ┃ ┃ ┣ 📜analysis_options.yaml  
 ┃ ┃ ┗ 📜pubspec.yaml  
 ┃ ┣ 📂routes  
 ┃ ┃ ┣ 📂lib  
 ┃ ┃ ┃ ┣ 📂src  
 ┃ ┃ ┃ ┃ ┗ 📜route_names.dart  
 ┃ ┃ ┃ ┗ 📜routes.dart  
 ┃ ┃ ┣ 📜analysis_options.yaml  
 ┃ ┃ ┗ 📜pubspec.yaml  
 ┃ ┗ 📂theme  
 ┃ ┃ ┣ 📂assets  
 ┃ ┃ ┃ ┣ 📂images  
 ┃ ┃ ┃ ┃ ┗ 📜empty_img.png  
 ┃ ┃ ┃ ┗ 📂svg  
 ┃ ┃ ┃ ┃ ┗ 📜empty_ico.svg  
 ┃ ┃ ┣ 📂lib  
 ┃ ┃ ┃ ┣ 📂src  
 ┃ ┃ ┃ ┃ ┣ 📂colors  
 ┃ ┃ ┃ ┃ ┃ ┗ 📜theme_colors.dart  
 ┃ ┃ ┃ ┃ ┣ 📂icons  
 ┃ ┃ ┃ ┃ ┃ ┗ 📜theme_icons.dart  
 ┃ ┃ ┃ ┃ ┣ 📂images  
 ┃ ┃ ┃ ┃ ┃ ┗ 📜theme_images.dart  
 ┃ ┃ ┃ ┃ ┣ 📂spacers  
 ┃ ┃ ┃ ┃ ┃ ┗ 📜theme_spacers.dart  
 ┃ ┃ ┃ ┃ ┣ 📂text_styles  
 ┃ ┃ ┃ ┃ ┃ ┗ 📜theme_text_styles.dart  
 ┃ ┃ ┃ ┃ ┗ 📂theme_datas  
 ┃ ┃ ┃ ┃ ┃ ┗ 📜theme_datas.dart  
 ┃ ┃ ┃ ┗ 📜theme.dart  
 ┃ ┃ ┣ 📜analysis_options.yaml  
 ┃ ┃ ┗ 📜pubspec.yaml  
 ┣ 📂features  
 ┃ ┗ 📂feat_example  
 ┃ ┃ ┣ 📂lib  
 ┃ ┃ ┃ ┣ 📂src  
 ┃ ┃ ┃ ┃ ┣ 📂config  
 ┃ ┃ ┃ ┃ ┃ ┗ 📜feat_example_const.dart  
 ┃ ┃ ┃ ┃ ┣ 📂data  
 ┃ ┃ ┃ ┃ ┃ ┣ 📂datasources  
 ┃ ┃ ┃ ┃ ┃ ┃ ┣ 📂local  
 ┃ ┃ ┃ ┃ ┃ ┃ ┃ ┗ 📜feat_example_local_datasource_impl.dart  
 ┃ ┃ ┃ ┃ ┃ ┃ ┣ 📂remote  
 ┃ ┃ ┃ ┃ ┃ ┃ ┃ ┗ 📜feat_example_remote_datasource_impl.dart  
 ┃ ┃ ┃ ┃ ┃ ┃ ┗ 📜feat_example_datasource.dart  
 ┃ ┃ ┃ ┃ ┃ ┣ 📂models  
 ┃ ┃ ┃ ┃ ┃ ┃ ┣ 📜feat_example_request_model.dart  
 ┃ ┃ ┃ ┃ ┃ ┃ ┗ 📜feat_example_response_model.dart  
 ┃ ┃ ┃ ┃ ┃ ┗ 📂repositories  
 ┃ ┃ ┃ ┃ ┃ ┃ ┗ 📜feat_example_repository_impl.dart  
 ┃ ┃ ┃ ┃ ┣ 📂di  
 ┃ ┃ ┃ ┃ ┃ ┗ 📜feat_example_provider.dart  
 ┃ ┃ ┃ ┃ ┣ 📂domain  
 ┃ ┃ ┃ ┃ ┃ ┣ 📂entities  
 ┃ ┃ ┃ ┃ ┃ ┃ ┗ 📜feat_example_entity.dart  
 ┃ ┃ ┃ ┃ ┃ ┣ 📂repositories  
 ┃ ┃ ┃ ┃ ┃ ┃ ┗ 📜feat_example_respository.dart  
 ┃ ┃ ┃ ┃ ┃ ┗ 📂usecases  
 ┃ ┃ ┃ ┃ ┃ ┃ ┗ 📜feat_example_usecase.dart  
 ┃ ┃ ┃ ┃ ┗ 📂presentation  
 ┃ ┃ ┃ ┃ ┃ ┣ 📂application  
 ┃ ┃ ┃ ┃ ┃ ┃ ┗ 📂feat_example_counter  
 ┃ ┃ ┃ ┃ ┃ ┃ ┃ ┣ 📜feat_example_counter_cubit.dart  
 ┃ ┃ ┃ ┃ ┃ ┃ ┃ ┗ 📜feat_example_counter_state.dart  
 ┃ ┃ ┃ ┃ ┃ ┣ 📂pages  
 ┃ ┃ ┃ ┃ ┃ ┃ ┗ 📜feat_example_page.dart  
 ┃ ┃ ┃ ┃ ┃ ┗ 📂widgets  
 ┃ ┃ ┃ ┃ ┃ ┃ ┗ 📜feat_example_widget.dart  
 ┃ ┃ ┃ ┗ 📜feat_example.dart  
 ┃ ┃ ┣ 📂test  
 ┃ ┃ ┃ ┗ 📂src  
 ┃ ┃ ┃ ┃ ┗ 📜feat_example_test.dart  
 ┃ ┃ ┣ 📜analysis_options.yaml  
 ┃ ┃ ┗ 📜pubspec.yaml  
 ┣ 📂ios  
 ┣ 📂resources  
 ┣ 📜.gitignore  
 ┣ 📜analysis_options.yaml  
 ┣ 📜pubspec.yaml  
 ┗ 📜README.md  

`core`: Contains all the core functionalities and configurations used by the packages under `features` and the main project.

`core/components`: Contains the common widgets for the whole app.

`core/dependencies`: The third party dependencies and core packages are exported here to be used in the whole app.

`core/di`: Dependency injection configuration.

`core/internationalization`: Contains the app internationalization configuration.

`core/network`: Place your network configuration here.

`core/routes`: Contains the names of the app routes.

`core/theme`: App theme configuration: theme data, colors, icons, images, etc.

`features`: Project well known and specific features with single responsability.

`features/feat_example`: Feature example.

`features/feat_example/.../data`: Contains repository and datasource implementations and service models.

`features/feat_example/.../data/datasources/local`: Local datasource implementation.

`features/feat_example/.../data/datasources/remote`: Remote datasource implementation.

`features/feat_example/.../data/models`: Request and response service models.

`features/feat_example/.../data/repositories`: Repository implementation.

`features/feat_example/.../di`: Feature dependency injection set up.

`features/feat_example/.../domain`: Contains entities and interfaces.

`features/feat_example/.../domain/entities`: Specific feature entities.

`features/feat_example/.../domain/repositories`: Specific feature repository interfaces.

`features/feat_example/.../domain/usecases`: Specific feature usecases.

`features/feat_example/.../presentation`: Feature visual components and business logic.

`features/feat_example/.../presentation/application`: Visual component's business logic.

`features/feat_example/.../presentation/pages`: Specific feature pages.

`features/feat_example/.../presentation/widgets`: Specific feature atomic widgets.

The rest of possible `create` command usages are the following:

```sh
# Create a new Flutter project named my_project
blue_bird create my_project

# Create a new Flutter project named my_project with a custom org
blue_bird create my_project --desc "My new Flutter project" --org "com.custom.org"

# Create a new Flutter project named my_project with a custom application id
blue_bird create my_project --application-id "com.custom.app.id"

# Create a new Flutter package named my_package (used for the feat_example package generation)
blue_bird create my_package --template flutter_package
```

---

[coverage_badge]: coverage_badge.svg
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
[very_good_cli_link]: https://github.com/VeryGoodOpenSource/very_good_cli