# Be sure to restart your server when you modify this file.

# Ddt::Application.config.session_store :cookie_store, key: '_ddt_session_key', expire_after: 30.days
Rails.application.config.session_store :active_record_store, key: '_ddt_session_key', expire_after: 30.days
