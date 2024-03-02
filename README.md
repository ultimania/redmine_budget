# Redmine Budget Controll plugin

This plugin can display the estimated hours and entry hours as a calendar for each user.

## Features

By selecting the user who wants to manage the budget and actual results and the year and month you want to display, you can view the status of the budget and actual results in a calendar format.

## Installation

Install the plugin in your Redmine plugins directory, clone this repository as `redmine_budget`:

```
cd {RAILS_ROOT}/plugins
git clone https://github.com/ultimania/redmine_budget.git redmine_budget
cd ../
bundle install --without development test
bundle exec rake redmine:plugins:migrate RAILS_ENV=production
```

**note: The directory name must be a `redmine_budget`. Directory name is different, it will fail to run the Plugin.**

## Usage
* Estimated hours(PV): The planned man-hours for each issue are calculated by dividing them proportionally by the period value, and the calculated values ​​are displayed on the calendar for each day and person in charge.
* Entry hours(AC): The working hours allocated to each issue on the target day are aggregated on a daily basis and displayed on the calendar.

## Supported versions

* Current version : Redmine 5.1.1 or later

## License

The plugin is available under the terms of the [GNU General Public License](http://www.gnu.org/licenses/gpl-2.0.html), version 2 or later.

## Author

[Takumi Fukaya](https://github.com/ultimania)

I am looking for people who are willing to become [sponsors](https://github.com/sponsors/ultimania) and contribute to maintaining this project.
