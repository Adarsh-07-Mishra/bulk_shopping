ActiveAdmin.register Account do
  permit_params :name, :price
  index do
    selectable_column
    id_column
    column 'Book Name', :name
    column :price
    column :created_at
    actions
  end
  form do |f|
    f.inputs do
      f.input :name
      f.input :price
    end
    f.actions
  end
end
