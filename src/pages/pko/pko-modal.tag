pko-modal
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title Приходный кассовый ордер
        #{'yield'}(to="body")
            form(onchange='{ change }', onkeyup='{ change }')
                .form-group
                    label.control-label Плательщик
                    input.form-control(name='customer', value='{ item.customer }', readonly)
                .form-group
                    label.control-label Основание
                    input.form-control(name='base', value='{ item.base }', readonly)
                .form-group
                    label.control-label Сумма оплаты
                    input.form-control(id='pko-amount', name='amount', value='{ item.amount }', type='number')

        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
            button(onclick='{ parent.opts.submit.bind(this) }', type='button', class='btn btn-primary btn-embossed') Сохранить

    script(type='text/babel').
        var self = this

        self.on('mount', () => {
            let modal = self.tags['bs-modal']
            modal.item = {
                idUser: opts.idUser,
                customer: opts.customer,
                base: opts.base,
                amount: opts.amount
            }

            modal.mixin('change')

        })
