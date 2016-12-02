import-settings
    .row
        .col-md-3: .form-group
            label.control-label Ключевое поле
            select.form-control(name='keyField', value='{ parent.item.keyField }')
                option(value='article') Артикул
                option(value='name') Наименование
        .col-md-3: .form-group
            label.control-label Папка рисунков
            input.form-control(name='folderImages', type='text', value='{ parent.item.folderImages }')
    .row
        .col-md-3: .form-group
            label.control-label Категория по умолчанию
            select.form-control(name='idGroup', value='{ parent.item.idGroup }')
                option(value='')
                option(each='{ parent.groups }', value='{ id }',
                selected='{ id == parent.parent.item.idGroup }', no-reorder) { name }
        .col-md-3: .form-group
            label.control-label Бренд по умолчанию
            select.form-control(name='idBrand', value='{ parent.item.idBrand }')
                option(value='')
                option(each='{ parent.brands }', value='{ id }',
                selected='{ id == parent.parent.item.idBrand }', no-reorder) { name }
    .row
        .col-md-3: .form-group
            button.btn.btn-danger(onclick='{ parent.back }', type='button') Назад
            button.btn.btn-primary(onclick='{ parent.exec }', type='button') Импорт