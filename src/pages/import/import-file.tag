import-file
    .row
        .col-md-3: .form-group
            label.control-label Файл импорта
            .input-group
                input.form-control(name='filename', value='{ parent.item.filename }', placeholder='Выберите файл',
                disabled='true')
                span.input-group-addon.btn-file.btn.btn-default(onchange='{ parent.changeFile }')
                    input(name='file', type='file', , accept='.csv,.xls,.xlsx')
                    i.fa.fa-fw.fa-folder-open
        .col-md-3: .form-group
            label.control-label Профиль загрузки
            select.form-control(name='profile', value='{ parent.item.idProfile }', onchange='{ parent.selectProfile }')
                option(value='')
                option(each='{ parent.profiles }', value='{ id }',
                selected='{ id == parent.item.idProfile }', no-reorder) { name }
    .row
        .col-md-3: .form-group
            label.control-label Кодировка
            select.form-control(name='encoding', value='{ parent.item.encoding }')
                option(value='auto') Автоопределение
                option(value='Windows-1251') Windows-1251
                option(value='UTF-8') UTF-8
        .col-md-3: .form-group
            label.control-label Разделитель столбцов
            select.form-control(name='separator', value='{ parent.item.separator }')
                option(value='auto') Автоопределение
                option(value=';') Точка с запятой
                option(value=',') Запятая
                option(value='\\9') Табуляция
    .row
        .col-md-3: .form-group
            label.control-label Пропустить строк
            input.form-control(name='skipCountRows', type='number', min='0', step='1', value='{ parent.item.skipCountRows }')
    .row
        .col-md-3: .form-group
            button.btn.btn-primary(onclick='{ parent.loadFile }', type='button', disabled='{ !parent.fileSelected }') Загрузить