class SpreeStaticContentHooks < Spree::ThemeSupport::HookListener
  insert_after :admin_configurations_menu do
    "<%= configurations_menu_item(I18n.t('store_credits'), admin_store_credits_url, I18n.t('manage_store_credits')) %>"
  end
  
    
  insert_after :admin_users_index_row_actions do
    %(&nbsp;
      <%= link_to_with_icon('add', t("add_store_credit"), new_admin_user_store_credit_url(user)) %>
     )     
  end
  
  insert_after :checkout_payment_step do
    %(
    <% if (current_user.store_credits_total > 0) %>
    <br style='clear:both;' />
    <p>You have <%= number_to_currency current_user.store_credits_total %> of store credits</p>
    <p>
      <label>Enter amount, which you want to use</label><br />
      <%= form.text_field :store_credit_amount, :size => 19 %>
    </p>
    <% end %>
    )
  end
  
  insert_after :account_my_orders, :partial => 'users/store_credits'
end
