<%@ Control Language="C#" AutoEventWireup="false" Inherits="Satrabel.OpenForm.Settings" CodeBehind="Settings.ascx.cs" %>
<%@ Register TagPrefix="dnn" TagName="Label" Src="~/controls/LabelControl.ascx" %>
<%@ Register TagPrefix="dnncl" Namespace="DotNetNuke.Web.Client.ClientResourceManagement" Assembly="DotNetNuke.Web.Client" %>

<dnncl:DnnCssInclude ID="customJS" runat="server" FilePath="~/DesktopModules/OpenContent/alpaca/css/alpaca-dnn.css" AddTag="false" />
<dnncl:DnnJsInclude ID="DnnJsInclude6" runat="server" FilePath="~/Resources/Shared/Components/UserFileManager/jquery.dnnUserFileUpload.js" Priority="106" />
<dnncl:DnnJsInclude ID="DnnJsInclude1" runat="server" FilePath="~/DesktopModules/OpenContent/js/alpaca-1.5.8/lib/handlebars/handlebars.js" Priority="106" ForceProvider="DnnPageHeaderProvider" />
<dnncl:DnnJsInclude ID="DnnJsInclude2" runat="server" FilePath="~/DesktopModules/OpenContent/js/alpaca-1.5.8/alpaca/web/alpaca.js" Priority="107" ForceProvider="DnnPageHeaderProvider" />
<dnncl:DnnJsInclude ID="DnnJsInclude11" runat="server" FilePath="~/DesktopModules/OpenContent/js/wysihtml/wysihtml-toolbar.js" Priority="109" ForceProvider="DnnPageHeaderProvider" />
<dnncl:DnnJsInclude ID="DnnJsInclude12" runat="server" FilePath="~/DesktopModules/OpenContent/js/wysihtml/parser_rules/advanced_and_extended.js" Priority="109" ForceProvider="DnnPageHeaderProvider" />
<dnncl:DnnJsInclude ID="DnnJsInclude7" runat="server" FilePath="~/DesktopModules/OpenContent/alpaca/js/fields/dnn/wysihtmlField.js" Priority="109" ForceProvider="DnnPageHeaderProvider" />
<dnncl:DnnCssInclude ID="DnnCssInclude1" runat="server" FilePath="~/DesktopModules/OpenContent/css/font-awesome/css/font-awesome.min.css" AddTag="false" />
<dnncl:DnnJsInclude ID="DnnJsInclude5" runat="server" FilePath="~/DesktopModules/OpenContent/alpaca/js/fields/dnn/ImageField.js" Priority="107" ForceProvider="DnnFormBottomProvider" />
<dnncl:DnnJsInclude ID="DnnJsInclude9" runat="server" FilePath="~/DesktopModules/OpenContent/alpaca/js/views/dnndefault.js" Priority="107" ForceProvider="DnnFormBottomProvider" />

<asp:Panel ID="ScopeWrapper" runat="server">
    <div class="dnnFormItem">
        <dnn:Label ID="scriptListLabel" ControlName="scriptList" runat="server" />
        <asp:DropDownList ID="scriptList" runat="server" />
    </div>

    <div id="field1" class="alpaca"></div>
    <asp:CustomValidator ID="CustomValidator" runat="server" ErrorMessage="CustomValidator" ControlToValidate="scriptList" ClientValidationFunction="ClientValidation"></asp:CustomValidator>
    <asp:HiddenField ID="hfData" runat="server" />
</asp:Panel>

<script type="text/javascript">
    function ClientValidation(sender, args) {
        if (args.Value != "") {
            //args.IsValid = false;
            //return;
        }
        var alp = $("#field1").alpaca("get");
        if (alp) {
            alp.refreshValidationState(true);
            if (alp.isValid(true)) {
                var value = alp.getValue();
                //alert(JSON.stringify(value, null, "  "));
                $("#<%= hfData.ClientID %>").val(JSON.stringify(value, null, "  "));
                return;
            }
            args.IsValid = false;
        }
        return;
    }

    /*globals jQuery, window, Sys */
    (function ($, Sys) {

        function setupStructSettings() {

            var moduleScope = $('#<%=ScopeWrapper.ClientID %>'),
        self = moduleScope,
        sf = $.ServicesFramework(<%=ModuleId %>);

        self.CreateForm = function () {
            var postData = {};
            //var getData = "tabId=<%=TabId %>&moduleId=<%=ModuleId %>";
            var getData = "";//"Template=" + $("#<%= scriptList.ClientID %>").val();
            var action = "Settings"; //self.getUpdateAction();

            $.ajax({
                type: "GET",
                url: sf.getServiceRoot('OpenForm') + "OpenFormAPI/" + action,
                data: getData,
                beforeSend: sf.setModuleHeaders
            }).done(function (config) {
                var ConnectorClass = Alpaca.getConnectorClass("default");
                connector = new ConnectorClass("default");
                connector.servicesFramework = sf;

                $.alpaca.Fields.DnnFileField = $.alpaca.Fields.FileField.extend({
                    setup: function () {
                        this.base();
                    },
                    afterRenderControl: function (model, callback) {
                        var self = this;
                        this.base(model, function () {
                            self.handlePostRender(function () {
                                callback();
                            });
                        });
                    },
                    handlePostRender: function (callback) {
                        //var self = this;
                        var el = this.control;
                        self.SetupFileUpload(el);
                        callback();
                    }
                });
                Alpaca.registerFieldClass("file", Alpaca.Fields.DnnFileField);

                $("#field1").alpaca({
                    "schema": config.schema,
                    "options": config.options,
                    "data": config.data,
                    "view": "dnn-edit",
                    "connector": connector,
                    "postRender": function (control) {
                        //$('#field1').dnnPanels();
                        //$('.dnnTooltip').dnnTooltip();
                    }
                });
            }).fail(function (xhr, result, status) {
                alert("Uh-oh, something broke: " + status);
            });
        };
        self.FormSubmit = function (data, href) {
            var postData = { form: data };
            var action = "Update"; //self.getUpdateAction();

            $.ajax({
                type: "POST",
                url: sf.getServiceRoot('Satrabel.OpenForm') + "OpenFormAPI/" + action,
                data: postData,
                beforeSend: sf.setModuleHeaders
            }).done(function (data) {
                //alert('ok:' + data);
                //self.loadSettings();
                window.location.href = href;
            }).fail(function (xhr, result, status) {
                alert("Uh-oh, something broke: " + status);
            });
        };

        self.SetupFileUpload = function (fileupload) {

            //$('#field1 input[type="file"]')
            $(fileupload).fileupload({
                dataType: 'json',
                url: sf.getServiceRoot('Satrabel.OpenContent') + "FileUpload/UploadFile",
                maxFileSize: 25000000,
                formData: { example: 'test' },
                beforeSend: sf.setModuleHeaders,
                add: function (e, data) {
                    //data.context = $(opts.progressContextSelector);
                    //data.context.find($(opts.progressFileNameSelector)).html(data.files[0].name);
                    //data.context.show('fade');
                    data.submit();
                },
                progress: function (e, data) {
                    if (data.context) {
                        var progress = parseInt(data.loaded / data.total * 100, 10);
                        data.context.find(opts.progressBarSelector).css('width', progress + '%').find('span').html(progress + '%');
                    }
                },
                done: function (e, data) {
                    if (data.result) {
                        $.each(data.result, function (index, file) {
                            //$('<p/>').text(file.name).appendTo($(e.target).parent().parent());
                            //$('<img/>').attr('src', file.url).appendTo($(e.target).parent().parent());

                            $(e.target).closest('.alpaca-container').find('.alpaca-field-image input').val(file.url);
                            $(e.target).closest('.alpaca-container').find('.alpaca-image-display img').attr('src', file.url);
                        });
                    }
                }
            }).data('loaded', true);
        }
        self.CreateForm();
    }

    $(document).ready(function () {

        setupStructSettings();
        Sys.WebForms.PageRequestManager.getInstance().add_endRequest(function () {
            setupStructSettings();
        });
    });

}(jQuery, window.Sys));
</script>
