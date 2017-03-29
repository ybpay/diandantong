# encoding: utf-8
module Ddt
  class Agentsys::Agents::PasswordsController < Devise::PasswordsController
    layout 'ddt/layouts/agentsys/agent'
  end
end
