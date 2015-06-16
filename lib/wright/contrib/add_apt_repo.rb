# Copyright (c) 2015 Andi Fink <finkzeug@gmail.com>
# Licensed under the MIT License (see LICENSE).

# Adds an apt repo.
#
# @example Add a repo to the apt sources
#   #!/usr/bin/env wright
#   AddAptRepo.new(
#     self,
#     name: 'docker',
#     key_id: '36A1D7869245C8950F966E92D8576A8BA88D21E9',
#     content: 'deb https://get.docker.com/ubuntu docker main'
#   ).call
#
# @example Add a repo with two entries to the apt sources
#   #!/usr/bin/env wright
#   AddAptRepo.new(
#     self,
#     name: 'grml-stable',
#     key_id: 'ECDEA787',
#     content: ['deb     http://deb.grml.org/ grml-stable main',
#               'deb-src http://deb.grml.org/ grml-stable main']
#   ).call
class AddAptRepo
  # @param wright [#file, #directory] the wright object
  # @param [Hash] opts the options to create a repo with
  # @option opts [String] :name the repo name
  # @option opts [String, Array<String>] :content the entries for the
  #   apt sources file
  # @option opts [String] :key_id the key ID of the repo signing key
  # @option opts [String] :keyserver the keyserver
  def initialize(wright, opts)
    @wright      = wright
    @name        = opts.fetch(:name)
    @content     = opts.fetch(:content)
    @key_id      = opts.fetch(:key_id)
    @keyserver   = opts.fetch(:keyserver, 'hkp://keyserver.ubuntu.com:80')
  end

  public

  # Creates or updates the apt repo source file. Retrieves the repo signing key
  # and runs +apt-get update+ if necessary.
  #
  # @return [Bool] +true+ if the apt repo was updated, +false+ otherwise
  def call
    create_keyfile
    updated = create_listfile
    updated
  end

  private

  attr_reader :wright, :name, :content, :key_id, :keyserver

  def create_keyfile
    wright.directory(File.dirname gpg_key_filename)
    wright.file(gpg_key_filename) { |f| f.mode = '444' }

    File.zero?(gpg_key_filename) &&
      fetch_gpg_key
  end

  def create_listfile
    listfile = wright.file(list_filename) do |f|
      f.content = listfile_content
      f.mode = '444'
      f.on_update = -> { system 'apt-get', 'update' }
    end
    listfile.updated?
  end

  def gpg_key_filename
    "/etc/apt/trusted.gpg.d/#{name}.gpg"
  end

  def fetch_gpg_key
    cmd = ['apt-key',
           '--keyring', gpg_key_filename,
           'adv',
           '--keyserver', keyserver,
           '--recv-keys', key_id]
    system(*cmd) || fail("Error fetching key #{key_id}")
  end

  def list_filename
    "/etc/apt/sources.list.d/#{name}.list"
  end

  def listfile_content
    Array(content).join("\n") + "\n"
  end
end
