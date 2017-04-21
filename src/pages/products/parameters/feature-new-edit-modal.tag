feature-new-edit-modal
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title Элемент списка параметра
        #{'yield'}(to="body")
            form(onchange='{ change }', onkeyup='{ change }')
                .row
                    .col-md-4
                        .well.well-sm
                            image-select(name='imagePath', alt='0', size='64', value='{ item.imagePath }')
                    .col-md-8
                        .form-group(class='{ has-error: error.value }')
                            label.control-label Наименование
                            input.form-control(name='value' type='text' value='{ item.value }' autofocus)
                            .help-block { error.value }
                        .form-group(class='{ has-error: error.color }')
                            label.control-label Код цвета (пример: #FE3458)
                            input.form-control(name='color', type='text', value='{ item.color }')
                            .help-block { error.color }

        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
            button(onclick='{ parent.opts.submit }', type='button', class='btn btn-primary btn-embossed') Сохранить
        
    script(type='text/babel').
        var self = this

        self.on('mount', () => {
            let modal = self.tags['bs-modal']

            modal.item = opts.item || {}

            modal.mixin('validation')
            modal.mixin('change')

            modal.rules = {
                value: 'empty'
            }

            modal.afterChange = e => {
                modal.error = modal.validation.validate(modal.item, modal.rules, e.target.name)
            }

        })