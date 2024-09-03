Rails.application.config.after_initialize do
    # Verifica si es el entorno adecuado para ejecutar la indexación
    if Rails.env.development? || Rails.env.production?
      # Realiza la indexación
      Book.import
      Rails.logger.info "Books have been indexed in OpenSearch"
    end
  end