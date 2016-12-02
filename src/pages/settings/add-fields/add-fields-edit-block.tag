add-fields-edit-block
    .row
        .col-md-12
            ul.nav.nav-tabs.m-b-2(if='{ value.length > 0 }')
                li(each='{ item, i in value }', class='{ active: activeTab === i }')
                    a(onclick='{ changeTab }')
                        span { item.name }

    .row
        .col-md-12
            add-fields-edit-block-group(if='{ value.length > 0 }', value='{ value[activeTab].items || [] }')

    script(type='text/babel').
        var self = this
        self.value = []

        Object.defineProperty(self.root, 'value', {
            get() {
                return self.value
            },
            set(value) {
                self.value = value || []
            }
        })

        self.activeTab = 0

        self.changeTab = e => {
            self.activeTab = e.item.i
        }

        self.on('update', () => {
            if (opts.value)
                self.value = opts.value

            if (opts.name)
                self.root.name = opts.name
        })

add-fields-edit-block-group
    form(each='{ field, i in value }', onchange='{ change }')
        .row
            .col-md-12
                .form-group(if='{ field.type == "string" }')
                    label.control-label { field.name }
                    input.form-control(value='{ field.value }')
                .form-group(if='{ field.type == "text" }')
                    label.control-label { field.name }
                    textarea.form-control(rows='5',
                    style='min-width: 100%; max-width: 100%;', value='{ field.value }')
                .form-group(if='{ field.type == "number" }')
                    label.control-label { field.name }
                    input.form-control(value='{ field.value }', type='number')
                .form-group(if='{ field.type == "select" }')
                    label.control-label { field.name }
                    select.form-control(value='{ field.value }')
                        option(each='{ option, k in field.values.split(",") }',
                        selected='{ option == field.value }') { option }
                .form-group(if='{ field.type == "checkbox" }')
                    label.control-label { field.name }
                    .checkbox(each='{ option, k in field.values.split(",") }')
                        label
                            input(type='checkbox', data-value='{ option }',
                            checked='{ field.value.split(",").indexOf(option) !== - 1 }')
                            | { option }
                .form-group(if='{ field.type == "radio" }')
                    label.control-label { field.name }
                    .radio(each='{ option, k in field.values.split(",") }')
                        label
                            input(name='{ field.name}', type='radio',
                            checked='{ field.value.split(",").indexOf(option) !== - 1 }', value='{ option }')
                            | { option }
                .form-group(if='{ field.type == "date" }')
                    label.control-label { field.name }
                    datetime-picker.form-control(format='YYYY-MM-DD', value='{ field.value }')

    script(type='text/babel').
        var self = this

        self.change = e => {
            e.stopPropagation()
            let type = e.item.field.type

            if (type !== 'checkbox') {
                e.item.field.value = e.target.value
            } else {
                let checkedValues = (e.item.field.value || '').split(',')
                let checkedValue = e.target.getAttribute('data-value')
                let idx = checkedValues.indexOf(checkedValue)

                if (idx !== -1)
                    checkedValues.splice(idx, 1)
                else
                    checkedValues.push(checkedValue)

                e.item.field.value = checkedValues.filter(i => i).join(',')
            }

            let event = document.createEvent('Event')
            event.initEvent('change', true, true)
            self.parent.root.dispatchEvent(event)
        }

        self.on('update', () => {
            if (opts.value)
                self.value = opts.value
        })