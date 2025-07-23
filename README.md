# Example Rails App for Reproducing Issues

This repository contains a minimal Rails application used to reproduce bugs and behaviors for submitting pull requests or opening issues in gems used in production. It allows sharing isolated examples without exposing proprietary code.

## Getting Started

### Prerequisites

- Ruby (see `.ruby-version` or Gemfile for version)
- Bundler (`gem install bundler`)
- SQLite3 (or your configured database)

### Setup

1. **Install dependencies:**
  ```sh
  bundle install
  ```

2. **Set up the database:**
  ```sh
  bin/rails db:setup
  ```

3. **Run the server:**
  ```sh
  bin/rails server
  ```

### Running Tests

To run the test suite:
```sh
bin/rails test
```
or, if using RSpec:
```sh
bundle exec rspec
```

### Customization

- Modify the Gemfile to add or remove gems as needed for your reproduction case.
- Add minimal code to demonstrate the issue.

### Contributing

Feel free to fork and adapt this project for your own bug reports or pull requests.

---

**Note:** This app is intentionally minimal and not intended for production use.
