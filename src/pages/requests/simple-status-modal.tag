simple-status-modal
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title Статус
        #{'yield'}(to="body")
            form(onchange='{ change }', onkeyup='{ change }')
                .form-group
                    label.control-label Новый статус
                    select.form-control(name='status', value='{ item.idStatus }')
                        option(value='0', selected='{ 0 == item.status }') Новый
                        option(value='1', selected='{ 1 == item.status }') В работе
                        option(value='2', selected='{ 2 == item.status }') Завершен

        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
            button(onclick='{ parent.opts.submit.bind(this) }', type='button', class='btn btn-primary btn-embossed') Сохранить

    script(type='text/babel').
        var self = this

        self.on('mount', () => {
            let modal = self.tags['bs-modal']
            modal.item = {
                status: opts.status
            }

            modal.mixin('change')

        })
