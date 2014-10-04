module ApplicationHelper
  def render_site_navigation(type)
    @site_navigation ||= {}
    @site_navigation[request.subdomain] ||= {
      'main' => [
             ['Home', root_path],
             ['Events', schedules_path, -> { params[:controller] == 'schedules' }],
        -> { ['Login', login_users_path] unless @team }
      ],

      'team' => [
        -> { [@team.name, team_path(@team)] },
             ['My Registrations', signups_path],
        -> { ['Change Password', edit_team_path(@team)] },
             ['Logout', logout_teams_path],
      ],

      'admin' => [
        -> { ['Tournament Settings', edit_admin_tournament_path(@current_tournament)] },
             ['School Settings', admin_school_edit_path],
             ['Manage Events', admin_schedules_path],
             ['Manage Teams', admin_teams_path],
             ['Scoring', admin_scores_path],
      ],
    }

    [
      render_nav_section(type, @site_navigation[request.subdomain]['main']),
      if @team
        render_nav_section(type, @site_navigation[request.subdomain]['team'], @team.coach)
      end,
      if @current_admin
        render_nav_section(type, @site_navigation[request.subdomain]['admin'], 'Admin Panel', admin_index_path)
      end,
    ].join.html_safe
  end

private

  def render_nav_section(type, section_links, heading = nil, heading_link = nil)
    if heading_link && heading
      heading_html = content_tag :h3, link_to(heading, heading_link), class: 'site-menu-section-header'
    elsif heading
      heading_html = content_tag :h3, heading, class: 'site-menu-section-header'
    else
      heading_html = ''
    end

    ul_classes = ('nav nav-pills nav-stacked' if type == :pills)

    heading_html +
      content_tag(:ul, class: ul_classes) do
        section_links.map do |item|
          nav_item = if item.respond_to?(:call)
                       item.call
                     else
                       item
                     end
          next if nav_item.nil?

          render_nav_item(*nav_item)
        end.compact.join.html_safe
      end
  end

  def render_nav_item(link_text, url, condition_lambda = nil)
    if condition_lambda.respond_to?(:call)
      active = condition_lambda.call
    else
      active = current_page?(url)
    end

    "<li#{' class="active"' if active}>#{link_to link_text, url}</li>"
  end
end
