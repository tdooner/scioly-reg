# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
Scioly::Application.config.secret_token = ENV['SECRET_TOKEN'] || '5e616aa1d3c5c600ed23ac544553d222338e185716dd4f1e9b1ead32dc533e5211b2a94c9af0dcbbce5d916da64c33be712368fbfd1e290dd89ae3c9ff10af71'
