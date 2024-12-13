class Api::V1::BackupPeController < ApplicationController
  skip_before_action :verify_authenticity_token

  def backup_backend
    system("clear")
    exist_main_folder || return
    list_paths.each_with_index do |path_microservice, index|
      process_microservice_folder(path_microservice, index)
    end
    render json: { message: "Process end #{params[:branch]}." }
  end

  def exist_main_folder
    main_folder = "../Portal Empresarial"
    if Dir.exist?(main_folder)
      puts "1. >>>>>>>>>>>>>>>>>>>> Main Folder exist #{main_folder}"
      true
    else
      error_message = "Main Folder #{main_folder} does not exist"
      puts ">>>>>>>>>>>>>>>>>>>> ERROR read_folder: #{error_message}"
      render json: { message: error_message }
      false
    end
  end

  def process_microservice_folder(path, index)
    Dir.chdir(path) do
      puts "\n2. #################### Folder #{index + 1}: #{path} ####################"
      git_fetch
      if git_track_checkout_branch || git_checkout_branch
        git_pull_source
        git_push_target
      end
      puts '====================================================================================================================='
    end
  rescue StandardError => e
    puts "Error processing folder #{path}: #{e.message}"
  end

  def git_fetch
    result_fetch = system("git fetch") unless Dir.exist?(".git 2>&1")
    puts "3. >>>>>>>>>>>>>>>>>>>> git fetch: #{result_fetch}"
  end

  def git_track_checkout_branch
    git_checkout = "git checkout  --track origin/#{list_repositories[:source][params[:branch].to_sym]}"
    puts "4. >>>>>>>>>>>>>>>>>>>> #{git_checkout}"
    result_checkout = system(git_checkout)
    puts "5. >>>>>>>>>>>>>>>>>>>> git checkout --track: #{result_checkout}"
    result_checkout
  end

  def git_checkout_branch
    git_checkout = "git checkout #{list_repositories[:source][params[:branch].to_sym]}"
    puts "6. >>>>>>>>>>>>>>>>>>>> #{git_checkout}"
    result_checkout = system(git_checkout)
    puts "7. >>>>>>>>>>>>>>>>>>>> git checkout: #{result_checkout}"
    result_checkout
  end

  def git_pull_source
    git_pull_source = "git pull #{list_repositories[:source][:name]} #{list_repositories[:source][params[:branch].to_sym]}"
    puts "8. >>>>>>>>>>>>>>>>>>>> #{git_pull_source}"
    result_pull_source = system(git_pull_source)
    puts "9. >>>>>>>>>>>>>>>>>>>> git pull: #{result_pull_source}"
  end

  def git_push_target
    git_push_target = "git push #{list_repositories[:target][:name]} #{list_repositories[:source][params[:branch].to_sym]}:#{list_repositories[:target][params[:branch].to_sym]} --no-verify"
    puts "10. >>>>>>>>>>>>>>>>>>>> #{git_push_target}"
    result_push_target = system(git_push_target)
    puts "11. >>>>>>>>>>>>>>>>>>>> git push: #{result_push_target}"
  end

  def list_paths
    [
      "../Portal Empresarial/portal-empresarial-aclaraciones-patronales/",
      "../Portal Empresarial/portal-empresarial-administracion-usuarios",
      "../Portal Empresarial/portal-empresarial-afiliatorio",
      "../Portal Empresarial/portal-empresarial-asociacion-disociacion-nrp",
      "../Portal Empresarial/portal-empresarial-autentica",
      "../Portal Empresarial/portal-empresarial-baja-registro-legal",
      "../Portal Empresarial/portal-empresarial-buzon-infonavit",
      "../Portal Empresarial/portal-empresarial-constancia-fiscal",
      "../Portal Empresarial/portal-empresarial-consulta-dictaminadores-autorizados",
      "../Portal Empresarial/portal-empresarial-consulta-notificadores-ejecutores",
      "../Portal Empresarial/portal-empresarial-consulta-trabajadores",
      "../Portal Empresarial/portal-empresarial-crea",
      "../Portal Empresarial/portal-empresarial-devoluciones-sua",
      "../Portal Empresarial/portal-empresarial-empresas-de-diez",
      "../Portal Empresarial/portal-empresarial-generador-pdf",
      "../Portal Empresarial/portal-empresarial-haz-cita",
      "../Portal Empresarial/portal-empresarial-incidencia",
      "../Portal Empresarial/portal-empresarial-login-crm",
      "../Portal Empresarial/portal-empresarial-medios-pago",
      "../Portal Empresarial/portal-empresarial-mi-perfil",
      "../Portal Empresarial/portal-empresarial-servicios-intercomunicacion",
      "../Portal Empresarial/portal-empresarial-sisub",
      "../Portal Empresarial/portal-empresarial-solicitudes",
      "../Portal Empresarial/portal-empresarial-tramite-credito",
    ]
  end

  def list_repositories
    {
      source: {
        name: "infonavit",
        develop: "desarrollo",
        qa: "qa",
        master: "release",
      },
      target: {
        name: "nextia",
        develop: "develop",
        qa: "staging",
        master: "master",
      },
    }
  end
end
