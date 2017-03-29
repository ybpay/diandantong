
    json.array! @branches do |branch|
        json.partial! partial: '/ddt/common_api/v1/branches/branch', locals: { branch: branch }
    end

