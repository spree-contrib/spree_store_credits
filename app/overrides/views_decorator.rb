Deface::Override.new(
  :virtual_path => "admin/configurations/index",
  :name => "store_credits_admin_configurations_menu",
  :insert_bottom => "[data-hook='admin_configurations_menu']",
  :text => "<%= configurations_menu_item(I18n.t('store_credits'), admin_store_credits_url, I18n.t('manage_store_credits')) %>",
  :disabled => false)

Deface::Override.new(
  :virtual_path => "admin/users/index",
  :name => "store_credits_admin_users_index_row_actions",
  :insert_bottom => "[data-hook='admin_users_index_row_actions']",
  :text => "&nbsp;<%= link_to_with_icon('add', t('add_store_credit'), new_admin_user_store_credit_url(user)) %>",
  :disabled => false)

Deface::Override.new(
  :virtual_path => "checkout/_payment",
  :name => "store_credits_checkout_payment_step",
  :insert_after => "[data-hook='checkout_payment_step']",
  :partial => "checkout/store_credits",
  :disabled => false)

Deface::Override.new(
  :virtual_path => "users/show",
  :name => "store_credits_account_my_orders",
  :insert_after => "[data-hook='account_my_orders']",
  :partial => "users/store_credits",
  :disabled => false)

Deface::Override.new(
  :virtual_path => "shared/_order_details",
  :name => "store_credits_order_details_adjustments",
  :insert_after => "[data-hook='order_details_adjustments']",
  :text => "
  <% if @order.store_credits.present? && !@order.completed? %>
    <tr><td colspan=\"4\">
    <%= check_box :order, :remove_store_credits %> <%= label :order, :remove_store_credits %>
    </td></tr>
  <% end %>",
  :disabled => false)


Deface::Override.new(:virtual_path => "admin/general_settings/show",
                     :name => "admin_general_settings_show_for_sc",
                     :insert_bottom => "[data-hook='preferences'], #preferences[data-hook]",
                     :text => "
<tr>
    <th scope=\"row\"><%= t(\"minimum_order_amount_for_store_credit_use\") %>:</th>
    <td><%=  Spree::Config[:use_store_credit_minimum] %></td>
</tr>",
                       :disabled => false)

Deface::Override.new(:virtual_path => "admin/general_settings/edit",
                     :name => "admin_general_settings_edit_for_sc",
                     :insert_bottom => "fieldset#preferences",
                     :text => "
  <p>
	<label><%= t(\"minimum_order_amount_for_store_credit_use\") %></label>
	<%= text_field_tag('app_configuration[preferred_use_store_credit_minimum]', Spree::Config[:use_store_credit_minimum]) %>
  </p>",
                     :disabled => false)

