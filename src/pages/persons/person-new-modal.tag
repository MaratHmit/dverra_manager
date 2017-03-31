| import 'inputmask'

person-new-modal(size='modal-sm')
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title Добавить новый контакт
        #{'yield'}(to="body")
            form(onchange='{ change }', onkeyup='{ change }')
                .form-group(class='{ has-error: error.name }')
                    label.control-label Имя
                    input.form-control(name='name', type='text')
                    .help-block { error.name }
                    label.control-label Телефон
                    input.form-control(name='phone', class='phone-mask', type='text')
                    .help-block { error.phone }
                    label.control-label Email
                    input.form-control(name='email', type='text')
        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
            button(onclick='{ parent.opts.submit.bind(this) }', type='button', class='btn btn-primary btn-embossed') Сохранить

    script(type='text/babel').
        var self = this

        self.on('mount', () => {
            let modal = self.tags['bs-modal']

            modal.item = {}
            modal.mixin('validation')
            modal.mixin('change')

            modal.rules = {
                name: 'empty',
                phone: 'empty'
            }

            modal.afterChange = e => {
                modal.error = modal.validation.validate(modal.item, modal.rules, e.target.name)
            }

            $('.phone-mask').mask("+7 (999) 999-99-99",{ "placeholder": " " })
        })