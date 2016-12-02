news-categories-edit-modal
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title Категория новости
        #{'yield'}(to="body")
            loader(if='{ loader }')
            form(if='{ !loader }', onchange='{ change }', onkeyup='{ change }')
                .form-group(class='{ has-error: error.name }')
                    label.control-label Наименование
                    input.form-control(name='name', value='{ item.name }')
                    .help-block { error.title }
                .form-group(class='{ has-error: error.code }')
                    label.control-label Код
                    input.form-control(name='code', value='{ item.code }')
                    .help-block { error.code }
        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Отмена
            button(onclick='{ parent.opts.submit }', type='button', class='btn btn-primary btn-embossed') Сохранить

    script(type='text/babel').
        var self = this

        self.on('mount', () => {
            let modal = self.tags['bs-modal']

            modal.item = {}
            modal.mixin('validation')
            modal.mixin('change')

            modal.rules = {
                name: 'empty'
            }

            modal.afterChange = e => {
                modal.error = modal.validation.validate(modal.item, modal.rules, e.target.name)
            }

            if (opts.id) {
                modal.loader = true

                API.request({
                    object: 'NewsCategory',
                    method: 'Info',
                    data: {id: opts.id},
                    success(response) {
                        modal.item = response
                    },
                    complete() {
                        modal.loader = false
                        modal.update()
                    }
                })
            }

        })