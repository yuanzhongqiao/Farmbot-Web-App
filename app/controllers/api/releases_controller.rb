module Api
  # ReleasesController accepts device information from an FBOS
  # device seeking to update its firmware.
  # It uses the information provided by FBOS to provide meta
  # data about the next appropriate release.
  class ReleasesController < Api::AbstractController
    RELEVANT_FIELDS = [:image_url, :version, :platform, :channel, :id]

    # GET /api/releases
    def show
      if !show_params[:platform]
        sorry "A `platform` param is required.", 422
        return
      end

      if release.version == current_device.fbos_version
        sorry "Already on the latest version.", 422
        return
      end

      render json: release
    end

    private

    def show_params
      @show_params ||= params
        .as_json
        .symbolize_keys
        .slice(*RELEVANT_FIELDS)
        .merge(channel: current_device.fbos_config.update_channel)
    end

    def release
      @release ||= Release.order(created_at: :desc).find_by!(show_params)
    end
  end
end