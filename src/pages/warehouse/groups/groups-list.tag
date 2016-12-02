| import 'components/catalog-tree.tag'

groups-units-list
    catalog-tree(object='UnitGroup', label-field='{ "name" }', children-field='{ "childs" }',
        add='{ add }',
        remove='{ remove }',
        handlers='{ handlers }', reload='true', search='true', )
        #{'yield'}(to='after')
            span { this[parent.childrenField].length ? "[" + this[parent.childrenField].length + "]" : "" }
            form.form-inline.pull-right
                button.btn.btn-default(if='{ handlers.checkPermission("products", "1000") }', type='button', onclick='{ handlers.open }')
                    i.fa.fa-pencil.text-primary
                button.btn.btn-default(if='{ handlers.checkPermission("products", "0100") }', type='button', onclick='{ handlers.add }')
                    i.fa.fa-plus.text-success
                button.btn.btn-default(if='{ handlers.checkPermission("products", "0001") }', type='button', onclick='{ handlers.remove }')
                    i.fa.fa-trash.text-danger

    style(scoped).
        :scope {
            position: relative;
            display: block;
        }

        treenodes .treenode {
            padding: 2px;
            width: 100%;
            display: inline-block;
            line-height: 2.2;
        }

    script(type='text/babel').
        var self = this

        self.mixin('permissions')
        self.mixin('remove')
        self.collection = 'UnitGroup'