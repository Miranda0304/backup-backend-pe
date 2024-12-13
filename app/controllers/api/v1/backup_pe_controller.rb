class Api::V1::BackupPeController < ApplicationController
  skip_before_action :verify_authenticity_token

  def initialize
    @MAIN_FOLDER = "../Portal Empresarial"
  end

  def backup_backend
    system("clear")
    exist_main_folder || return
    list_paths.each_with_index do |path_microservice, index|
      process_microservice_folder(path_microservice, index)
    end
    render json: { message: "Branch #{params[:branch]} finished." }
  end

  def exist_main_folder
    if Dir.exist?(@MAIN_FOLDER)
      puts "1. >>>>>>>>>>>>>>>>>>>> Main Folder exist #{@MAIN_FOLDER}"
      true
    else
      error_message = "Main Folder #{@MAIN_FOLDER} does not exist"
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
        if git_pull_source
          git_push_target
        end
      end
      puts "====================================================================================================================="
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
    result_pull_source
  end

  def git_push_target
    git_push_target = "git push #{list_repositories[:target][:name]} #{list_repositories[:source][params[:branch].to_sym]}:#{list_repositories[:target][params[:branch].to_sym]} --no-verify"
    puts "10. >>>>>>>>>>>>>>>>>>>> #{git_push_target}"
    result_push_target = system(git_push_target)
    puts "11. >>>>>>>>>>>>>>>>>>>> git push: #{result_push_target}"
  end

  def list_paths
    [
      "#{@MAIN_FOLDER}/portal-empresarial-aclaraciones-patronales/",
      "#{@MAIN_FOLDER}/portal-empresarial-administracion-usuarios",
      "#{@MAIN_FOLDER}/portal-empresarial-afiliatorio",
      "#{@MAIN_FOLDER}/portal-empresarial-asociacion-disociacion-nrp",
      "#{@MAIN_FOLDER}/portal-empresarial-autentica",
      "#{@MAIN_FOLDER}/portal-empresarial-baja-registro-legal",
      "#{@MAIN_FOLDER}/portal-empresarial-buzon-infonavit",
      "#{@MAIN_FOLDER}/portal-empresarial-constancia-fiscal",
      "#{@MAIN_FOLDER}/portal-empresarial-consulta-dictaminadores-autorizados",
      "#{@MAIN_FOLDER}/portal-empresarial-consulta-notificadores-ejecutores",
      "#{@MAIN_FOLDER}/portal-empresarial-consulta-trabajadores",
      "#{@MAIN_FOLDER}/portal-empresarial-crea",
      "#{@MAIN_FOLDER}/portal-empresarial-devoluciones-sua",
      "#{@MAIN_FOLDER}/portal-empresarial-empresas-de-diez",
      "#{@MAIN_FOLDER}/portal-empresarial-generador-pdf",
      "#{@MAIN_FOLDER}/portal-empresarial-haz-cita",
      "#{@MAIN_FOLDER}/portal-empresarial-incidencia",
      "#{@MAIN_FOLDER}/portal-empresarial-login-crm",
      "#{@MAIN_FOLDER}/portal-empresarial-medios-pago",
      "#{@MAIN_FOLDER}/portal-empresarial-mi-perfil",
      "#{@MAIN_FOLDER}/portal-empresarial-servicios-intercomunicacion",
      "#{@MAIN_FOLDER}/portal-empresarial-sisub",
      "#{@MAIN_FOLDER}/portal-empresarial-solicitudes",
      "#{@MAIN_FOLDER}/portal-empresarial-tramite-credito",
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
