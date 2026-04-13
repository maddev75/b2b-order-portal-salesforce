public class accCreation {
/*JS
 * import { LightningElement, track, api, wire } from "lwc";

import Twist_UI from "@salesforce/resourceUrl/Twist_UI";
import apexInitComponentConfig from "@salesforce/apex/TWIST_Registration.initComponentConfig";
import apexTranslateLabels from "@salesforce/apex/TWIST_i18nTranslations.translateLabelsList";
import isValidCode from "@salesforce/apex/TWIST_Registration.isValidCode";
import submitRegistrationForm from "@salesforce/apex/TWIST_Registration.submitRegistrationForm";
import getTermConditionLink from "@salesforce/apex/TWIST_Registration.getTermConditionLink";
import apexIsUserIdentity from "@salesforce/apex/TWIST_Account_Confirmation.isUserIdentity";
import apexDoesPasswordContainUserFirstNameOrLastName from "@salesforce/apex/TWIST_Registration.doesPasswordContainUserFirstNameOrLastName";
import apexHashEmail from '@salesforce/apex/TWIST_Utils.getEmailHash';

import { loadScript } from 'lightning/platformResourceLoader';
import libphonenumber from '@salesforce/resourceUrl/libphonenumber';

import {
    isEmailValid,
    showPageLoader,
    hidePageLoader,
    hasHeightChars,
    hasDigit,
    hasUpperCaseLetter,
    hasLowerCaseLetter,
    hasSpecialChar,
    doesPasswordMatchStringPattern,
    allowTriggerNewPageViewEvent,
    sendPageView,
    sendEvent,
    lwcNameToCamelCase,
    hasLegalAge,
    includesString,
    setFieldErrorMessage,
    removeFieldErrorMessage,
    showLineSocialLoginButton,
    showLineTaiwanSocialLoginButton,
    showLineThailandSocialLoginButton,
    showKakaoSocialLoginButton,
    showGoogleSocialLoginButton,
    showSmsConsent,
    showGoogleCustomerMatchConsent,
    showOrSeparator,
    isMobileDevice
} from 'c/twistUtils';

export default class TwistAccountCreation extends LightningElement {
    /* Component properties ******************************************************************** */

   /* @api queryParams;
    @api autodata;

    oQueryParams;
    passwordValidityCriteriaElt = null;
    twistLineLogo = Twist_UI + '/Twist_Line_Social_Login_Logo.svg';
    twistKakaoLogo = Twist_UI + '/kakao-logo.svg';
    twistLogoLV = Twist_UI + "/SmallLogo.png";
    chevronLV = Twist_UI + "/Chevrons.svg";
    twistGoogleLogo = Twist_UI + '/logo_google.svg';
    twistEyeIcon = Twist_UI + "/visibility-stroke.svg";
    twistEyeStrikeThroughIcon = Twist_UI + "/visibility.svg";
    twistCloseIcon = Twist_UI + '/Close.svg';
    currentSection;
    registrationFormField;
    socialParams;
    passKey;
    libphonenumberScriptLoaded = false;
    selectedCallingCode = '';
    phoneMasks = {};
    
    @api language;
    @api langCountry;
    @api showModalJuso;

    @track isPasswordShown = false;
    @track isConfirmPasswordShown = false;
    @track doesEmailExist = false;
    @track formData = {};
    @track isCreateYourAccountButtonDisabled = false;
    @track componentConfig = {};
    @track customLabels = {};
    @track form = { error: null };
    @track verificationCode;
    @track socialMediaProviders = {};
    @track newCodeGeneratedMessage;
    @track isLogInModalDisplayed = false;
    @track isDisabledLoginButton=false;
    @track loginModalErrorMsg;
    @track ariaInvalid = false;
    @track koreanAddressFields = false;
    @track koreaAddressButton = '';
    @track selectedAddress;
    @track selectedAddressFromChild;
    @track addressJusoData = {
        postal_code: '',
        state: '',
        city: '',
        address1: '',
        address2: '',
        address3: '',
        mobilePhone: '',
      };
      @track phoneNumber;
      @track showCountryPlaceholder = false;
      @track isGlobalConsentChecked;
      @track isSMSConsentChecked;
      @track isGCMConsentChecked;
      @track isEmailConsentChecked;
      @track showModalGCM = false;
      @track countryOptions = [];
      @track emptyComboboxFields = {
        country: false,
        title: false,
    };

    @wire(getTermConditionLink, { langCountry: "$oQueryParams.langCountry" }) termAndConditionLink;

    connectedCallback() {
        this.init();

        loadScript(this, libphonenumber ).then(() => {
            this.libphonenumberScriptLoaded  = true;
        }).catch(error => {
            // Handle error loading the script
             console.error('Error loading libphonenumber-js', error);
        });
    }

    renderedCallback() {
        this.passwordValidityCriteriaElt = this.template.querySelector("c-twist-password-validity-criteria");
    }

    errorCallback(error, stack) {
        console.error(error);
    }

    get currentPhoneMask() {
        return this.phoneMasks.phoneMaskPatterns?.[this.selectedCallingCode] || ''; // Default mask
    }

    get phonePlaceholder() {
        return this.currentPhoneMask;
    }

   // Set maxLength based on the current mask
   get phoneMaxLength() {
    return this.currentPhoneMask ? this.currentPhoneMask.length : this.registrationFormField.mobile_phone?.Validation_Max_Length__c;
}

    init() {
        this.oQueryParams = JSON.parse(this.queryParams);
        this.displayErrorMessageFromQueryParam();
        this.dispatchCanModalBeShownEvent();
        Promise.all([
            apexInitComponentConfig({ queryParams: this.oQueryParams }),
            apexTranslateLabels({
                labels: [
                    "Twist_Account_Creation_Form_ContinueButtonLabel",
                    "Twist_Account_Creation_Form_ActivateButtonLabel",
                    "Twist_Account_Creation_TitleActivateYourAccount",
                    "Twist_Account_Creation_TextAccountCreation",
                    "Twist_Account_Creation_TitleAccountCreation",
                    "Twist_Account_Creation_EmailFieldLabel",
                    "Twist_Account_Creation_EmailConfirmationFieldLabel",
                    "Twist_Account_Creation_PasswordFieldLabel",
                    "Twist_Account_Creation_TitleFieldLabel",
                    "Twist_Account_Creation_FirstNameFieldLabel",
                    "Twist_Account_Creation_LastNameFieldLabel",
                    "Twist_Account_Creation_FirstName2FieldLabel",
                    "Twist_Account_Creation_LastName2FieldLabel",
                    "Twist_Account_Creation_CountryFieldLabel",
                    "Twist_Account_Creation_DateOfBirthFieldLabel",
                    "Twist_Account_Creation_CheckFieldLabel",
                    "Twist_Account_Creation_CheckFieldLinkLabel",
                    "Twist_Account_Creation_EndTextAccountCreation",
                    "Twist_Account_Creation_ActivationCodeSecondeLineText",
                    "Twist_Account_Creation_ActivationCodeText",
                    "Twist_Account_Creation_AccountCodeFieldLabel",
                    "Twist_Account_Creation_SendAgainLink",
                    "Twist_Account_Creation_TermAndConditionsLink",
                    "Twist_Account_Creation_ByCreatingText",
                    "Twist_Account_Creation_LoginHereLink",
                    "Twist_Account_Creation_ConfirmationText",
                    "Twist_Account_Creation_Validation_EmailDoNotMatch",
                    "Twist_Login_Form_Validation_Email_Format",
                    "Twist_Form_FieldCantBeEmpty",
                    "Twist_Account_Creation_TitleConfirmationPage",
                    "IDENTITY_Registration_Verification_Section_Error",
                    "Twist_Reset_Password_Form_Validation_PasswordContainsEmail",
                    "Twist_Reset_Password_Form_Validation_PasswordContainsFirstOrLastNames",
                    "Twist_Reset_Password_Form_Validation_PasswordDoesNotMatchValidityCriteria",
                    "Twist_Reset_Password_Form_Validation_PasswordIsTooLong",
                    "Twist_Reset_Password_Form_Validation_WordCharacters",
                    "TWIST_Registration_Verification_IncorrectCode_Error",
                    "TWIST_Registration_Verification_Code_Limit",
                    "Twist_Account_Creation_Title_Placeholder",
                    "Twist_Account_Creation_Country_Placeholder",
                    "Twist_Reset_Password_Form_ConfirmPasswordFieldLabel",
                    "Twist_Partial_Activation_Form_PartialActivationYourEmailText",
                    "Twist_Partial_Activation_Form_PartialActivationSubtitle",
                    "Twist_Account_Creation_Form_AccountCreationProcessError",
                    "Twist_Account_Creation_SecondTextAccountCreation",
                    "Twist_Account_Creation_Form_AccountCreationRegexNotMatch",
                    "Twist_Account_Creation_Validation_RestrictionBirthdate",
                    "Twist_Account_Creation_Form_AccountUserExistsError",
                    "Twist_Account_Creation_AccountNewCodeGeneratedLabel",
                    "Twist_Login_Page_Social_Login_Line",
                    "Twist_Login_Page_Social_Login_Kakao",
                    "Twist_Social_Line_Text_For_Second_Option",
                    "Twist_Account_Creation_Wrong_birthdate",
                    "Twist_Account_Creation_Age_Legal_Reached",
                    "Twist_Account_Creation_CheckFieldLabel_Privacy_Policy",
                    'Twist_Login_Page_Social_Login_Google',
                    "Twist_Account_Creation_CheckFieldLabel_Newsletter",
                    "Twist_Account_Creation_BirthDate_Inconsistent",
                    "Twist_Reset_Password_Form_Validation_PasswordsDoNotMatch",
                    "Twist_RequiredFieldsLabel",
                    "Twist_Account_Creation_TitleAccountCreation",
                     "Twist_Account_Creation_KISA_Title",
                     "Twist_Account_Creation_KISA_Short_Description",
                     "Twist_Account_Creation_KISA_Accept_all_3_terms",
                     "Twist_Account_Creation_KISA_LV_Conditions",
                     "Twist_Account_Creatio_KISA_Using_Data",
                     "Twist_Account_Creation_KISA_Transferring",
                     "Twist_Account_Creation_KISA_Transferring_Notify",
                     "Twist_Account_Creation_KISA_Age",
                     "Twist_Account_Creation_Riskified_Kisa",
                     "Twist_Account_Creation_LV_Connect_Kisa_Send",
                     "Twist_Account_Creation_KISA_View_Details",
                     "Twist_Account_Creation_Korea_Address_Button",
                     "Twist_Account_Creation_Postal_Code_Label",
                     "Twist_Account_Creation_Text_Under_Postal_Code_Label",
                     "Twist_Account_Creation_State_Label",
                     "Twist_Account_Creation_City_Label",
                     "Twist_Account_Creation_Address1_Label",
                     "Twist_Account_Creation_Address2_Label",
                     "Twist_Account_Creation_Address3_Label",
                     "Twist_Account_Creation_Phone_Example_Label",
                     "Twist_Account_Creation_Mobile_Phone_Label",
                     "Twist_Account_Creation_Juso_Button",
                     "Twist_Account_Creation_Search_Address",
                     "Twist_Account_Creation_Confirm_Juso_Address",
                     "Twist_Account_Creation_Address_Search_Juso",
                     "Twist_Account_Creation_Korea_Address_Button",
                     "Twist_Account_Creation_Error_Message_Juso",
                     "Twist_Account_Creation_No_Results_Juso",
                     "Twist_Account_Creation_Invalid_Format_Field_Error",
                     "Twist_Activation_Email_Section_Description",
                     "Twist_Account_Creation_CheckFieldLabel_GCM_SmsConsent",
                     "Twist_Account_Creation_CheckFieldLabel_GCM_SmsConsent_Without_Link",
                     "Twist_Account_Creation_CheckFieldLabel_Preferences",
                     "Twist_Account_Creation_CheckFieldLabel_Email",
                     "Twist_Account_Creation_CheckFieldLabel_SMS",
                     "Twist_Account_Creation_CheckFieldLabel_GCM",
                     "Twist_Account_Creation_CheckFieldLinkLabel_GCM",
                     "Twist_Account_Creation_CheckFieldModalContent_GCM",
                     "Twist_Account_Creation_PhoneHelpText",
                     "Twist_Account_Creation_Newsletter_Personal_Data_Consent_Part_One",
                     "Twist_Account_Creation_Newsletter_Personal_Data_Consent_Part_Two",
                     "Twist_Account_Creation_Newsletter_Personal_Data_Consent_Part_Tree",
                     "Twist_Account_Creation_Newsletter_Personal_Data_Consent_Part_Four",
                     "Twist_Account_Creation_Newsletter_Personal_Data_Consent_Part_Five",
                     "Twist_Account_Creation_CheckFieldLabel_Newsletter_Korea",
                     "Twist_Account_Creation_CheckFieldLabel_Newsletter_Korea_Text",
                     "Twist_Account_Creation_CheckFieldLabel_Newsletter_Korea_Text_Two"
                ],
                language: this.language
            })
        ])
        .then((result) => {
            this.componentConfig = result[0];
            if (result[0].mode === "LOGIN") {
                this.handleClickOnLoginHereLink();
                return;
            }

            this.currentSection = result[0].showCurrentSection;
            this.formData = result[0]?.formData ? { ...result[0]?.formData } : { ...result[0]?.socialParams };
            this.socialParams = { ...result[0]?.socialParams };
            this.passKey = result[0]?.passKey ?? '';

            this.registrationFormField = result[0]?.form;
            this.maxPasswordLength = result[0]?.form?.password?.Validation_Max_Length__c ?? 20;


            if (this.componentConfig.client_country) {
                this.countryOptions = this.componentConfig.countryList.map((country) => ({
                    label: country.label,
                    value: country.value,
                    selected: country.value === this.componentConfig.client_country,
                }));
                this.formData.country = this.componentConfig.client_country;
            }
            else{
                this.showCountryPlaceholder = true;
            }

            this.customLabels = result[1];
            this.socialMediaProviders = result[0]?.socialMediaProviders;
            this.selectedCallingCode = this.registrationFormField.calling_code?.Default_Value__c;
            this.formData.calling_code = this.selectedCallingCode;
            this.phoneMasks = result[0]?.phoneMasks;
            this.formData.newsletter_agreement = this.registrationFormField.newsletter_agreement?.Default_Value__c?.trim().toLowerCase() || "false";
            this.isEmailConsentChecked = this.formData.newsletter_agreement === "true";
            if(this.isGlobalConsentActivated){
                this.isGlobalConsentChecked = this.isEmailConsentChecked;
                if(this.showSmsConsent){
                    this.formData.SMS_agreement = this.registrationFormField.SMS_agreement?.Default_Value__c?.trim().toLowerCase() || "false";
                    this.isSMSConsentChecked = this.formData.SMS_agreement === "true";
                }
                if(this.showGoogleCustomerMatchConsent){
                    this.formData.GCM_agreement = this.registrationFormField.GCM_agreement?.Default_Value__c?.trim().toLowerCase() || "false";
                    this.isGCMConsentChecked = this.formData.GCM_agreement === "true";
                }
            }
        })
        .catch((error) => {
            this.form.error = `Error: ${error}`;
        })
        .finally(() => {
            if(this.componentConfig.mode != 'LOGIN'){
                this.dispatchEvent(new CustomEvent("childlwcrendered", { detail: lwcNameToCamelCase(this.template.host.localName) }));
            }
        });
    }

    /* Getters & Setters ********************************************************************************* */

   /* get componentForm(){
        return this.componentConfig.mode == "PARTIAL_ACTIVATION"? 'component__form is--accountActivation' : 'component__form';
    }

    get isKisaFields() {
        return this.currentSection == 0;
    }

    get isCurrentSectionAccountCreation() {
        return this.currentSection == 1;
    }

    get isCurrentSectionActivateYourAccount() {
        return this.currentSection == 2;
    }

    get isCurrentSectionConfirmationMessage() {
        return this.currentSection == 3;
    }

    get regexNoDigitAndSpecialChars() {
        return "^[\\p{L}\\p{M}'\\-\\s]+$"; // except hyphen and single quote
    }

    get postalCodeRegex (){
        return '^[a-zA-Z0-9!@#$%^&*()_+-=]{5,10}$';
    }

    get addressRegex (){
        return '^[\\u0020-\\u007E\\u0080-\\uFFFF]{1,40}$';
    }

    get stateRegex(){
        return '.+';
    }

    get cityRegex(){
        return '^[^\\d]+$';
    }

    get isGlobalError() {
        return this.form.error;
    }

    get isEmailDisabled() {
        return this.componentConfig.modeInfo.isEmailReadOnly || this.isLogInModalDisplayed;
    }

    set emailInSystem(val) {
        this.doesEmailExist = val;
        if (this.doesEmailExist) {
            this.setErrorMessage(this.registrationFormField.email.Field__c, this.customLabels.Twist_Account_Creation_Form_AccountUserExistsError);
        }
    }

    get emailInSystem() {
        if (this.doesEmailExist) {
            this.setErrorMessage(this.registrationFormField.email.Field__c, this.customLabels.Twist_Account_Creation_Form_AccountUserExistsError);
        }
        return this.doesEmailExist;
    }

    get passwordFieldType() {
        return this.isPasswordShown ? "text" : "password";
    }

    get eyeIconSrcPassword() {
        return this.isPasswordShown ? this.twistEyeStrikeThroughIcon : this.twistEyeIcon;
    }

    get eyeIconSrcConfirmPassword() {
        return this.isConfirmPasswordShown ? this.twistEyeStrikeThroughIcon : this.twistEyeIcon;
    }

    get confirmPasswordFieldType() {
        return this.isConfirmPasswordShown ? "text" : "password";
    }

    get showCountryField(){
        return this.registrationFormField.country && this.componentConfig.showCountryList;
    }

    get showOrText() {
        return showOrSeparator.call(this);
    }

    get showLineButton() {
        return showLineSocialLoginButton.call(this);
    }

    get showLineTWButton() {
        return showLineTaiwanSocialLoginButton.call(this);
    }

    get showLineTHButton() {
        return showLineThailandSocialLoginButton.call(this);
    }

    get showGoogleButton() {
        return showGoogleSocialLoginButton.call(this);
    }

    get containerClassName() {
        const baseClass = "subscribe-text";
        const mobileSuffix = isMobileDevice() ? (this.isGlobalConsentActivated ? " global-consent-mobile" : " mobile") : "";
        return `${baseClass}${mobileSuffix}`;
    }    

    get showKakaoButton() {
        return showKakaoSocialLoginButton.call(this);
    }

    get isRequired() {
        return this.isKoreanFieldsRequired();
    }

    get showGoogleCustomerMatchConsent() {
        return showGoogleCustomerMatchConsent.call(this);
    }

    get showSmsConsent() {
        return showSmsConsent.call(this);
    }

    get termsGlobalClassName() {
        return isMobileDevice() ? "global-consent-terms mobile" : "global-consent-terms";
    }

    get isGlobalConsentActivated(){
        return this.showGoogleCustomerMatchConsent || this.showSmsConsent;
    }

    get isSMSCheckedWithoutPhoneFilled(){
        return !this.template.querySelector('[data-id="mobile_phone"]')?.value && this.isSMSConsentChecked;
    }

    get countryFormElementClass() {
        return this.emptyComboboxFields.country
            ? 'slds-form-element slds-has-error'
            : 'slds-form-element';
    }

    get titleFormElementClass() {
        return this.emptyComboboxFields.title
            ? 'slds-form-element slds-has-error'
            : 'slds-form-element';
    }
  
    /* Event handlers ************************************************************************** */

    /*handleTwistGaLwcRendered() {
        sendPageView.call(this); // Tagging Plan: line 42
    }

    handlePaste(event) {
        event.preventDefault();
    }

    handleOnKeyPress(event) {
        if (this.doesNotMatchRegexp(event.key, this.regexNoDigitAndSpecialChars)) {
            event.preventDefault();
        }
    }

    handleInputBlur(event){
        const targetId = event?.detail?.targetId || event.target.dataset.id;
        const value = event?.detail?.value || event.target.value;
        const oldValue = this.formData[targetId];

        if (Object.keys(this.registrationFormField).includes(targetId) && targetId !== this.registrationFormField.mobile_phone?.Field__c) {
            this.formData[targetId] = value;
        }
        const isFieldInvalid = this.isFieldInvalid(targetId);
        switch(targetId) {
            case this.registrationFormField.email?.Field__c:
                if (value) {
                    if (oldValue != value) {
                        this.doesEmailExist = false;
                        this.ariaInvalid = false
                    }
                    if (!this.doesEmailExist && !isFieldInvalid) {
                        this.checkIfUserExists();
                    }
                }
                else{
                    this.ariaInvalid = true
                }
                break;

            case this.registrationFormField.password.Field__c:
                this.handleFormPasswordBlur();
                break;
        }
        return isFieldInvalid;
    }
    handlePhoneNumberChange(event) {
        const rawValue = event ? event.detail.value.replace(/\D/g, '') : this.phoneNumber.replace(/\D/g, '');
        const mask = this.currentPhoneMask; // mask of country
        let digitIndex = 0;
        let formattedValue = '';

        if (!mask) {
            this.phoneNumber = rawValue;
            return;
        }

        // Format of phone number according the mask
        formattedValue  = [...mask].reduce((acc, char) => {
            if (char === this.phoneMasks.phoneMaskChar) {
                // Ajouter un chiffre si disponible dans rawValue
                if (digitIndex < rawValue.length) {
                    acc += rawValue[digitIndex++];
                }
            } else {
                // Ajouter les séparateurs seulement après avoir ajouté un chiffre
                if (digitIndex > 0 && rawValue.length > digitIndex) acc += char;
            }
            return acc;
        }, '');

       this.phoneNumber = formattedValue;
    }

    isValidPhone(targetId) {
        if (!this.libphonenumberScriptLoaded ) {
          // Library still not loaded
          console.error('Libphonenumber-js is not yet loaded');
          return; // Or handle this gracefully in your UI
        }

        try {
            const target = this.template.querySelector(`[data-id="${targetId}"]`);
            const phoneNumber = window['libphonenumber'].parsePhoneNumber(target.value.replace(/-/g, ""), this.selectedCallingCode);
            if (phoneNumber) {
                let formattedPhoneNumber = '';
                this.isValidNumberPhone = phoneNumber.isValid();

                if (this.isValidNumberPhone) {
                    formattedPhoneNumber = phoneNumber.format('INTERNATIONAL').replace(/\s+/g, '');
                    this.formData[targetId] = formattedPhoneNumber;
                    return true;
                } else {
                    return false;
                }
            } else {
               return false;
            }
        } catch (error) {
            console.error("Error when calling parse", error);
            return false;
        }
    }

    handleCheckboxChange(event) {
        let targetId = event.target.dataset.id;
        let value = event.target.checked;
        sendEvent.call(this, { // Tagging Plan: lines 31 & 32
            actionId: value ? "tick_checkbox" : "untick_checkbox",
            categoryGa: "mylv",
            actionGa: value ? "tick_checkbox" : "untick_checkbox",
            contentId: "newsletter_subscription",
            actionType: "newsletter_subscription"
        });
        if (Object.keys(this.registrationFormField).includes(targetId)) {
            this.formData[targetId] = String(value);
        }

        if(this.isGlobalConsentActivated){
            this.updateGlobalConsentSMSAndGCM();
        }
        if(this.isSMSConsentChecked){
            this.checkIfPhoneFilled();
        }
        this.isFieldInvalid(targetId);
    }

    handleCheckboxChangePrivacyPolicy(event) {
        let targetId = event.target.dataset.id;
        let value = event.target.checked;
       /* sendEvent.call(this, { // Tagging Plan: lines 31 & 32
            actionId: value ? "tick_checkbox" : "untick_checkbox",
            categoryGa: "mylv",
            actionGa: value ? "tick_checkbox" : "untick_checkbox",
            contentId: "privacy_policy",
            actionType: "privacy_policy"
        });*/


        /*if (Object.keys(this.registrationFormField).includes(targetId)) {
            this.formData[targetId] = String(value);
        }
        this.isFieldInvalid(targetId);
        // For now we don't need to store the information
    }

    handleComboboxesChange(event) {
        const targetId = event.target.dataset.id;
        const target = this.template.querySelector(`[data-id="${targetId}"]`);
        if(targetId === this.registrationFormField.calling_code?.Field__c) {
            this.selectedCallingCode = event.detail.value;
            this.handlePhoneNumberChange();
        }
        if (Object.keys(this.registrationFormField).includes(targetId)) {
            this.formData[targetId] = target.value;
        }
        
        this.isFieldInvalid(targetId);
    }

    handleFormPasswordChange(event) {
        if (!this.passwordValidityCriteriaElt) {
            this.passwordValidityCriteriaElt = this.template.querySelector("c-twist-password-validity-criteria");
        }

        const password = event.target.value;
        this.formData.password = password;

        this.passwordValidityCriteriaElt.setCheckIconRegardingCriteria_HasHeightChars(hasHeightChars(password));
        this.passwordValidityCriteriaElt.setCheckIconRegardingCriteria_HasDigit(hasDigit(password));
        this.passwordValidityCriteriaElt.setCheckIconRegardingCriteria_HasUpperCaseLetter(hasUpperCaseLetter(password));
        this.passwordValidityCriteriaElt.setCheckIconRegardingCriteria_HasLowerCaseLetter(hasLowerCaseLetter(password));
        this.passwordValidityCriteriaElt.setCheckIconRegardingCriteria_HasSpecialChar(hasSpecialChar(password));

        const fieldDataId = this.registrationFormField.password.Field__c;
        removeFieldErrorMessage(this.template.querySelector(`[data-id="${fieldDataId}"]`));
        if (this.isFieldRequiredAndEmpty(fieldDataId, password)) {
            this.setErrorMessage(fieldDataId, this.customLabels.Twist_Form_FieldCantBeEmpty);
        }
        if (this.doesPasswordContainsEmail()) {
            this.setErrorMessage(fieldDataId, this.customLabels.Twist_Reset_Password_Form_Validation_PasswordContainsEmail);
        }
        if (this.doesPasswordContainsFirstOrLastNames()) {
            this.setErrorMessage(fieldDataId, this.customLabels.Twist_Reset_Password_Form_Validation_PasswordContainsFirstOrLastNames);
        }
        if (!doesPasswordMatchStringPattern(password)) {
            this.setErrorMessage(fieldDataId, this.customLabels.Twist_Reset_Password_Form_Validation_PasswordDoesNotMatchValidityCriteria);
        }
        if (this.isPasswordTooLong()) {
            this.setErrorMessage(fieldDataId, `${this.customLabels.Twist_Reset_Password_Form_Validation_PasswordIsTooLong} ${this.maxPasswordLength} ${this.customLabels.Twist_Reset_Password_Form_Validation_WordCharacters}`);
        }
    }

    handleFormPasswordFocus(event) {
        this.passwordValidityCriteriaElt = this.template.querySelector("c-twist-password-validity-criteria");
        this.passwordValidityCriteriaElt.show(true);
    }

    async handleFormPasswordBlur(event) {
        if (this.componentConfig.modeInfo?.isPartialActivationMode && await this.doesPasswordContainUserFirstNameOrLastNameBackendCheck(this.formData.password, this.oQueryParams.cid)) {
            this.setErrorMessage(this.registrationFormField.password?.Field__c, this.customLabels.Twist_Reset_Password_Form_Validation_PasswordContainsFirstOrLastNames);
        }
        this.passwordValidityCriteriaElt = this.template.querySelector("c-twist-password-validity-criteria");
        this.passwordValidityCriteriaElt.show(false);
    }

    handleClickOnLoginHereLink() {
        sendEvent.call(this, { // Tagging Plan: line 30
            actionId: "i_already_have_an_account",
            categoryGa: "mylv",
            actionGa: "create_an_account",
            labelGa: "i_already_have_an_account"
        });
        let urlSplit = location.href.split("?");
        location.href = this.componentConfig.loginBaseUrl
            + "?"
            + urlSplit[1]
            + (this.oQueryParams.dispatchCountry ? "&dispatchCountry=" + this.oQueryParams.dispatchCountry : "");
    }

    handleClickOnCreateYourAccountButton(event) {
        if (this.isFormValid()) {
            this.isCreateYourAccountButtonDisabled = true;
            showPageLoader();
        }
    }

    handleCodeChange(event) {
        if (!event.target.value) {
            this.setErrorMessage(event.target.dataset.id, this.customLabels.Twist_Form_FieldCantBeEmpty);
        }
        this.verificationCode = event.target.value;
    }

    handleTermConditionClick() {
        if (this.termAndConditionLink != null) {
            window.open(this.termAndConditionLink.data);
        }
    }
  
    handleClickOnContinueButton() {
        if(!this.isFormValid()) {
            sendEvent.call(this, { // Tagging Plan: line 55
                pageName: "mylv/account_creation/step_personal_infos",
                actionId: "account_creation_step_failed",
                categoryGa: "mylv",
                actionGa: "create_an_account",
                labelGa: "account_creation_step_failed",
                errorId: this.getErrorFieldsList()
            });
        }
        else {
            showPageLoader();
            this.sendVerificationCode();
            this.sendHashedEmailToGA4();
        }
    }

    handleResendVerificationCode(event) {
        sendEvent.call(this, { // Tagging Plan: line 58
            pageName: "mylv/account_creation/step_activation",
            actionId: "resend_activation_code",
            categoryGa: "mylv",
            actionGa: "create_an_account",
            labelGa: "resend_activation_code"
        });

        this.disableLink(event.target.dataset.id);
        this.handleClickOnContinueButton();
    }

    handleClickOnActivateAccountButton() {
        try{
            sendEvent.call(this, { // Tagging Plan: line 33
                actionId: "account_creation_request",
                categoryGa: "mylv",
                actionGa: "create_an_account",
                labelGa: "account_creation_request"
            });
            if(this.verificationCode) {
                this.checkCodeIsValid();
            }
            else {
                this.setErrorMessage("activationCode", this.customLabels.Twist_Form_FieldCantBeEmpty);
            }
        }
        catch(e){
            console.error(e);
            this.setErrorMessage("activationCode", "error");
            hidePageLoader();
        }
    }

    handleKeypressOnActivationCode(e) {
        if (e.keyCode === 13) {
            this.handleClickOnActivateAccountButton();
            e.preventDefault();
        }
    }

    handleResetFieldBirthday(e) {
        this.formData[this.registrationFormField.birthdate.Field__c] = "";
    }

    handleToggleShowPassword(event) {
        this.isPasswordShown = !this.isPasswordShown;
        sendEvent.call(this, { // Tagging Plan: line 54
            actionId: this.isPasswordShown ? "show_password" : "hide_password",
            categoryGa: "mylv",
            actionGa: "create_an_account",
            labelGa: this.isPasswordShown ? "show_password" : "hide_password"
        });
    }

    handleToggleShowConfirmPassword(event) {
        this.isConfirmPasswordShown = !this.isConfirmPasswordShown;
    }

    handleClickOnContinueWithoutActivationCodeButton() {
        if(!this.isFormValid()) {
            sendEvent.call(this, { // Tagging Plan: line 55
                actionId: "account_creation_failed",
                categoryGa: "mylv",
                actionGa: "create_an_account",
                labelGa: "account_creation_failed",
                errorId: this.getErrorFieldsList()
            });
        }
        else {
            showPageLoader();
            //submitform
            submitRegistrationForm({
                formData: this.formData,
                queryParams: this.oQueryParams,
                socialParams: this.socialParams,
                doNeedVerificationCode: false
            })
            .then(data => {
                hidePageLoader();
                if(!data.success) {
                    sendEvent.call(this, { // Tagging Plan: line 55
                        actionId: "account_creation_failed",
                        categoryGa: "mylv",
                        actionGa: "create_an_account",
                        labelGa: "account_creation_failed",
                        errorId: data.form
                    });


                    this.form.error = data.form;
                }
                else {
                    sendEvent.call(this, { // Tagging Plan: line 33
                        actionId: "account_creation_request",
                        categoryGa: "mylv",
                        actionGa: "create_an_account",
                        labelGa: "account_creation_request"
                    });

                    this.showConfirmationMessageSection();


                }
            })
            .catch((error) => {
                console.error("error", error);
            })
            .finally(() => {
                hidePageLoader();
            });
        }
    }

    handleClickSendKisaCheckboxes(){
        this.currentSection +=1;
    }

    handleShowModal() {
        this.template.querySelector('c-twist-juso-address-search').openModal();
    }

    handleSelectedAddressChange(event){
        this.selectedAddressFromChild = event.detail.selectedValue;
    }

    handleModalConfirm(event) {
        this.selectedAddressFromChild = event.detail.selectedValue;
        if (this.selectedAddressFromChild) {
            this.addressJusoData = {
                ...this.addressJusoData,
                postal_code: this.selectedAddressFromChild.zipNo,
                state: this.selectedAddressFromChild.siNm,
                city: this.selectedAddressFromChild.sggNm !== '' ? this.selectedAddressFromChild.sggNm : this.selectedAddressFromChild.state,
                address1: this.selectedAddressFromChild.emdNm,
                address2: `${this.selectedAddressFromChild.rn}${this.selectedAddressFromChild.buldMnnm}${!['0', ''].includes(this.selectedAddressFromChild.buldSlno) ? `-${this.selectedAddressFromChild.buldSlno}` : ''}`
            };

            for (const key in this.addressJusoData) {
                const inputField = this.template.querySelector(`[data-id="${key}"]`);
                if (inputField) {
                    inputField.value = this.addressJusoData[key];
                    this.formData[key] =  inputField.value;
                }
            }
        }
    }

    handleKeyPressOnPhone(event) {
        const keyCode = event.keyCode || event.which;
        const keyValue = String.fromCharCode(keyCode);

        if (!/^[0-9]+$/.test(keyValue)) {
            event.preventDefault();
        }
    }

    handleKisaCheckboxChange(event) {
        // Fusionner les valeurs des cases à cocher KISA avec formData
        this.formData = { ...this.formData, ...event.detail };
    }

    handleTab(event) {
        if (event.key === 'Tab') {
            const allFields = this.template.querySelectorAll('[data-id]');
            const currentElement = event.target;
            const index = Array.from(allFields).indexOf(currentElement);

            if (event.shiftKey) {
                //  Shift + Tab
                if (index > 0) {
                    event.preventDefault();
                    allFields[index - 1].focus();
                }
            } else {
                // Tab normal
                if (index < allFields.length - 1) {
                    event.preventDefault();
                    allFields[index + 1].focus();
                }
            }
        }
    }
    handleGlobalConsentChange(event) {
       
        const isGlobalChecked = event.target.checked;
       
        if (isGlobalChecked) {
            this.formData.newsletter_agreement = 'true'; 
            this.isGlobalConsentChecked = true;
            this.isEmailConsentChecked = true;
        } 
        else {
            this.formData.newsletter_agreement = 'false';
            this.formData.GCM_agreement = 'false';
            this.formData.SMS_agreement = 'false';
            this.isGlobalConsentChecked = false;
            this.isGCMConsentChecked = false;
            this.isSMSConsentChecked = false;
            this.isEmailConsentChecked = false;
        }       
    }
    
    handleClickOnGCMModalLink() {
        this.showModalGCM = true;
    }

    handleGCMModalClose() {
        this.showModalGCM = false;
    }


    /* Util methods **************************************************************************** */


    /*showKoreanAddressFields(){
        this.koreanAddressFields = true;
        this.koreaAddressButton = 'hideButton';
    }

    hideKoreanAddressFields() {
        this.koreanAddressFields = false;
        this.koreaAddressButton = 'showButton';
    }

      displayErrorMessageFromQueryParam() {
        this.form.error = this.oQueryParams.error;
      }

    doesNotMatchRegexp(term, pattern) {
        var regex = new RegExp(pattern, "u");
        return term && !regex.test(term);
    }

    showActivateYourAccountSection() {
        this.currentSection = 2;
        this.dispatchCanModalBeShownEvent();

        allowTriggerNewPageViewEvent.call(this); // required because a pageView event has already been sent from this page
        sendPageView.call(this, { pageName: "mylv/account_creation/step_activation" }); // Tagging Plan: line 53
    }

    showConfirmationMessageSection() {
        this.currentSection = 3;
        this.dispatchCanModalBeShownEvent();
    }

    dispatchCanModalBeShownEvent() {
        this.dispatchEvent(new CustomEvent("canmodalbeshown", { detail: this.currentSection == 2 }));
    }

    checkIfUserExists() {
        apexIsUserIdentity({ email : this.formData.email })
        .then(result => {
            if(this.componentConfig.modeInfo.isSocialLogin && result) { // email exists and sociallogin flow -> open popup
                this.isLogInModalDisplayed = true;
            }
            else{
                this.emailInSystem = result;
                if (this.emailInSystem) {
                    this.ariaInvalid = true;
                    sendEvent.call(this, { // Tagging Plan: line 43
                        actionId: "email_not_valid",
                        categoryGa: "mylv",
                        actionGa: "create_an_account",
                        labelGa: "email_not_valid"
                    });
                }
            }
        })
    }

    sendVerificationCode() {
        submitRegistrationForm({
            formData: this.formData,
            queryParams: this.oQueryParams,
            socialParams: this.socialParams,
            doNeedVerificationCode: true
        })
        .then(data => {
            hidePageLoader();
            const id = 'resendCode';
            if(!data.success) {
                sendEvent.call(this, { // Tagging Plan: line 55
                    pageName: "mylv/account_creation/step_personal_infos",
                    actionId: "account_creation_step_failed",
                    categoryGa: "mylv",
                    actionGa: "create_an_account",
                    labelGa: "account_creation_step_failed",
                    errorId: data.form
                });

                if (!data.success) {
                    this.setErrorMessage("activationCode", data.form);
                }
                this.form.error = data.form;

                if(this.isCurrentSectionActivateYourAccount){ // in case of too many send again requests
                    this.newCodeGeneratedMessage = null;
                    this.disableLink(id);
                }
            }
            else {
                sendEvent.call(this, { // Tagging Plan: line 56
                    pageName: "mylv/account_creation/step_personal_infos",
                    actionId: "account_creation_step_succeeded",
                    categoryGa: "mylv",
                    actionGa: "create_an_account",
                    labelGa: "account_creation_step_succeeded"
                });


                if (this.isCurrentSectionAccountCreation) {
                    this.showActivateYourAccountSection();
                    return;
                }


                if (this.isCurrentSectionActivateYourAccount) {
                    this.activateLink(id);
                    this.newCodeGeneratedMessage = this.customLabels.Twist_Account_Creation_AccountNewCodeGeneratedLabel;
                }
            }
        })
        .catch((error) => {
            console.error("error", error);
        })
        .finally(() => {
            hidePageLoader();
            // Scroll up the page
            window.scrollTo({
                top: 0,
                left: 0,
                behavior: 'smooth'
            });
        });
    }

    disableLink(id) {
        const target = this.template.querySelector(`[data-id="${id}"]`);
        if (target) {
            target.classList.add("disabled-link");
            target.disabled = true;
        }
    }

    activateLink(id){
        const target = this.template.querySelector(`[data-id="${id}"]`);
        setTimeout(function(){
            if(target){
                target.classList.remove('disabled-link');
                target.disabled = false;
            }
        }, 60000);
    }

    checkCodeIsValid() {
        showPageLoader();
        isValidCode({
            language: this.language,
            activationCode: this.verificationCode,
            identifier: this.formData.email,
            queryParams: this.oQueryParams,
            socialParams: this.socialParams
        })
        .then(isValid => {
            sendEvent.call(this, { // Tagging Plan: line 59
                pageName: "mylv/account_creation/step_activation",
                actionId: isValid ? "account_creation_step_succeeded" : "account_creation_step_failed",
                categoryGa: "mylv",
                actionGa: "create_an_account",
                labelGa: isValid ? "account_creation_step_succeeded" : "account_creation_step_failed"
            });
            if (isValid){
                this.showConfirmationMessageSection();
            }
            else {
                this.setErrorMessage("activationCode", this.customLabels.TWIST_Registration_Verification_IncorrectCode_Error);
            }
        })
        .catch(error => {
            this.setErrorMessage("activationCode", "error")
            console.error("error", error);
        })
        .finally(() => {
            hidePageLoader();
        })
    }

    getErrorFieldsList() {
        let fields = [];
        Object.keys(this.registrationFormField).forEach((element) => {
            if (this.isFieldInvalid(this.registrationFormField[element].Field__c)) {
                fields.push(this.registrationFormField[element].Field__c);
            }
        });
        return fields.join(";");
    }

    sendHashedEmailToGA4() {
        apexHashEmail({
            email: this.formData.email
        })
        .then(response => {
            if (response.success) {
                sendEvent.call(this, { 
                    event: "click",
                    categoryGa: "mkey_submitted",
                    actionGa: "mkey_submitted",
                    actionId: "mkey_submitted",
                    mkey: response.emailHash
                });
            }
        })
    }

    updateGlobalConsentSMSAndGCM() {
        this.isEmailConsentChecked = this.formData.newsletter_agreement ? JSON.parse(this.formData.newsletter_agreement) : false;
        this.isSMSConsentChecked = this.formData.SMS_agreement ?  JSON.parse(this.formData.SMS_agreement) : false;
        this.isGCMConsentChecked = this.formData.GCM_agreement ?  JSON.parse(this.formData.GCM_agreement) : false;
        
        const allUnchecked = !this.isEmailConsentChecked && ! this.isSMSConsentChecked && ! this.isGCMConsentChecked;
        this.isGlobalConsentChecked = !allUnchecked;
    }

    /* Form validation methods **************************************************************************** */

    /*isFormValid() {
        let isValid = true;
        Object.values(this.registrationFormField).forEach(fieldObject => {
            if (this.isFieldInvalid(fieldObject.Field__c)) {
                isValid = false;
            }
            if (this.langCountry === 'kor-kr' && this.isKoreanFieldsRequired()) {
                isValid = false;
            }
        });
        return isValid;
    }

    /**
     * @param {String} fieldDataId
     * @returns {Boolean}
     */
    /*isFieldInvalid(fieldDataId) {
        if (!this.getFieldElement(fieldDataId) || this.getFieldElement(fieldDataId).value?.trim() === '') {
            return false;
        }
        const fieldValue = this.formData[fieldDataId];

        if (this.isFieldRequiredAndEmpty(fieldDataId, fieldValue)) {
            this.setErrorMessage(fieldDataId, this.customLabels.Twist_Form_FieldCantBeEmpty);
            return true;
        }

        this.removeErrorMessage(fieldDataId);

        switch (fieldDataId) {
            case this.registrationFormField.email?.Field__c:
                const isEmailFieldInvalid = !isEmailValid(fieldValue, this.componentConfig.AllowPlusSymbolInEmail) || fieldValue?.toLowerCase().includes("info@");
                if (isEmailFieldInvalid) {
                    this.ariaInvalid = true;
                    this.setErrorMessage(fieldDataId, this.customLabels.Twist_Login_Form_Validation_Email_Format);
                    sendEvent.call(this, { // Tagging Plan: line 43
                        actionId: "email_not_valid",
                        categoryGa: "mylv",
                        actionGa: "create_an_account",
                        labelGa: "email_not_valid"
                    });
                }
                else{
                    this.ariaInvalid = false;
                }
                return isEmailFieldInvalid;


            case this.registrationFormField.emailconfirmation?.Field__c:
                const doEmailsMismatch = (this.formData.email !== fieldValue);
                if (doEmailsMismatch) {
                    this.setErrorMessage(fieldDataId, this.customLabels.Twist_Account_Creation_Validation_EmailDoNotMatch);
                    sendEvent.call(this, { // Tagging Plan: line 44
                        actionId: "emails_dont_match",
                        categoryGa: "mylv",
                        actionGa: "create_an_account",
                        labelGa: "emails_dont_match"
                    });
                }
                return doEmailsMismatch;


            case this.registrationFormField.birthdate?.Field__c:
                if (this.isCurrentSectionAccountCreation) {
                    if (this.isFutureDate(fieldValue)) {
                        this.setErrorMessage(fieldDataId, this.customLabels.Twist_Account_Creation_BirthDate_Inconsistent);
                        return true;
                    }
                    if (!hasLegalAge(fieldValue, this.componentConfig.legalAge)) {
                        this.setErrorMessage(fieldDataId, this.customLabels.Twist_Account_Creation_Validation_RestrictionBirthdate);
                    }
                }
                return false;


            case this.registrationFormField.password?.Field__c:
                if (this.doesPasswordContainsEmail()) {
                    this.setErrorMessage(fieldDataId, this.customLabels.Twist_Reset_Password_Form_Validation_PasswordContainsEmail);
                    return true;
                }
                if (this.doesPasswordContainsFirstOrLastNames()) {
                    this.setErrorMessage(fieldDataId, this.customLabels.Twist_Reset_Password_Form_Validation_PasswordContainsFirstOrLastNames);
                    return true;
                }
                if (!doesPasswordMatchStringPattern(fieldValue)) {
                    this.setErrorMessage(fieldDataId, this.customLabels.Twist_Reset_Password_Form_Validation_PasswordDoesNotMatchValidityCriteria);
                    return true;
                }
                if (this.isPasswordTooLong()) {
                    this.setErrorMessage(fieldDataId, `${this.customLabels.Twist_Reset_Password_Form_Validation_PasswordIsTooLong} ${this.maxPasswordLength} ${this.customLabels.Twist_Reset_Password_Form_Validation_WordCharacters}`);
                    return true;
                }
                return false;

            case this.registrationFormField.passwordconfirmation?.Field__c:
                if (fieldValue !== this.formData.password) {
                    this.setErrorMessage(fieldDataId, this.customLabels.Twist_Reset_Password_Form_Validation_PasswordsDoNotMatch);
                    return true;
                }
                return false;

            case this.registrationFormField.firstname?.Field__c:
            case this.registrationFormField.lastname?.Field__c:
            case this.registrationFormField.firstname2?.Field__c:
            case this.registrationFormField.lastname2?.Field__c:
                if (this.doesNotMatchRegexp(fieldValue, this.regexNoDigitAndSpecialChars)) {
                    this.setErrorMessage(fieldDataId, this.customLabels.Twist_Account_Creation_Form_AccountCreationRegexNotMatch);
                    return true;
                }
                return false;

            case this.registrationFormField.country?.Field__c:
            case this.registrationFormField.title?.Field__c:
            case this.registrationFormField.newsletter_agreement?.Field__c:
            case this.registrationFormField.privacy_policy?.Field__c:

            return false;

            case this.registrationFormField.postal_code?.Field__c:

            if (this.doesNotMatchRegexp(fieldValue, this.postalCodeRegex)) {
                    this.setErrorMessage(fieldDataId, this.customLabels.Twist_Account_Creation_Invalid_Format_Field_Error);
                    return true;
                }

            return false;

            case this.registrationFormField.state?.Field__c:
                if (this.doesNotMatchRegexp(fieldValue, this.stateRegex)) {
                        this.setErrorMessage(fieldDataId, this.customLabels.Twist_Account_Creation_Invalid_Format_Field_Error);
                        return true;
                    }

            return false;

            case this.registrationFormField.city?.Field__c:
               if (this.doesNotMatchRegexp(fieldValue, this.cityRegex)) {
                        this.setErrorMessage(fieldDataId, this.customLabels.Twist_Account_Creation_Invalid_Format_Field_Error);
                        return true;
                    }

            return false;

            case this.registrationFormField.address1?.Field__c:
            case this.registrationFormField.address2?.Field__c:
            case this.registrationFormField.address3?.Field__c:

            if (this.doesNotMatchRegexp(fieldValue, this.addressRegex)) {
                this.setErrorMessage(fieldDataId, this.customLabels.Twist_Account_Creation_Invalid_Format_Field_Error);
                return true;
            }
            return false;

            case this.registrationFormField.mobile_phone?.Field__c:
                if (!this.isValidPhone(fieldDataId)) {
                    this.setErrorMessage(fieldDataId, this.customLabels.Twist_Account_Creation_Phone_Error);
                    return true;
                }
                return false;

            case this.registrationFormField.calling_code?.Field__c: break;

            default: return false;
        }
        return false;
    }
    /**
     * @param {String} fieldDataId
     * @param {*} fieldValue
     * @returns {Boolean}
     */
    /*isFieldRequiredAndEmpty(fieldDataId, fieldValue) {
        if (!this.registrationFormField[fieldDataId].Is_Required__c) {
            return false;
        }
        const fieldElement = this.getFieldElement(fieldDataId);
        return (fieldElement.type !== undefined && fieldElement.type === 'checkbox')
            ? fieldValue !== "true"
            : !fieldValue;
    }

    /**
     * @param {String} fieldDataId
     */
    /*setErrorMessage(fieldDataId, errorMessage) {
        if (fieldDataId === this.registrationFormField.birthdate?.Field__c) {
            this.template.querySelector("c-date-input-format").setErrorMessage(errorMessage);
        }
        else {
            setFieldErrorMessage(this.template.querySelector(`[data-id="${fieldDataId}"]`), errorMessage);
        }
    }

    /**
     * @param {String} fieldDataId
     */
    /*removeErrorMessage(fieldDataId) {
        this.setErrorMessage(fieldDataId, "");
    }

    doesPasswordContainsEmail() {
        return includesString(this.formData.password, this.formData.email);
    }

    doesPasswordContainsFirstOrLastNames() {
        return includesString(this.formData.password, this.formData.firstname) || includesString(this.formData.password, this.formData.lastname); 
    }
    
    async doesPasswordContainUserFirstNameOrLastNameBackendCheck(password, cid) {
        try {
            const invalidPassword = await apexDoesPasswordContainUserFirstNameOrLastName({ 
                password: password, 
                activation_client_encrypted: cid 
            });
            return invalidPassword;
        } catch (error) {
            console.error("error", error);
            return null; 
        }
    }

    isPasswordTooLong() {
        return (this.formData.password == undefined || !this.formData.password)
            ? false
            : this.formData.password.length > this.maxPasswordLength;
    }

    /**
     * @param {String} stringDate (YYYY-MM-DD format)
     * @return {Boolean}
     */
    /*isFutureDate(stringDate) {
        if (stringDate !== undefined && stringDate) {
            const today = new Date();
            const parts = stringDate.split('-');
            const aDate = new Date(today); // clone object
            aDate.setFullYear(parts[0]);
            aDate.setMonth(Number(parts[1]) - 1, parts[2]);
            return aDate >= today;
        }
        return false;
    }

    /**
     * @param {String} fieldDataId
     * @return {Element}
     */
    /*getFieldElement(fieldDataId) {
        return (fieldDataId == this.registrationFormField.birthdate?.Field__c)
            ? this.template.querySelector("c-date-input-format")?.getDateFieldElement()
            : this.template.querySelector(`[data-id="${fieldDataId}"]`);
    }

    /**
     * @returns {Boolean}
     */
    /*isKoreanFieldsRequired() {
        const postalCode = this.template.querySelector('[data-id="postal_code"]')?.value;
        const state = this.template.querySelector('[data-id="state"]')?.value;
        const city = this.template.querySelector('[data-id="city"]')?.value;
        const address1 = this.template.querySelector('[data-id="address1"]')?.value;
        const address2 = this.template.querySelector('[data-id="address2"]')?.value;
        const address3 = this.template.querySelector('[data-id="address3"]')?.value;
        const prefix = this.template.querySelector('[data-id="calling_code"]')?.value;
        const mobilePhone = this.template.querySelector('[data-id="mobile_phone"]')?.value;

        const isAtLeastOneKoreanFieldFilled =
          postalCode || state || city || address1 || address2 || address3 || mobilePhone || prefix;

            if (isAtLeastOneKoreanFieldFilled) {
                return !postalCode || !state || !city || !address1 || !address2 || !address3 || !mobilePhone || !prefix;
            }
            return false;
    }

    checkIfPhoneFilled(){
        const phoneField = this.template.querySelector('[data-id="mobile_phone"]');
        if(phoneField && !phoneField.value){
            phoneField.focus();
        }
    }

    validateRequiredField() {
        const countryValue = this.template.querySelector(`[data-id="${this.registrationFormField.country?.Field__c}"]`).value;
        this.emptyComboboxFields.country = !countryValue;

        const titleValue = this.template.querySelector(`[data-id="${this.registrationFormField.title?.Field__c}"]`).value;
        this.emptyComboboxFields.title = !titleValue;
    }
}*/
    // HTML
    /*<template>
    <div class="main">

        <c-twist-google-analytics autodata={autodata} ontwistgalwcrendered={handleTwistGaLwcRendered}></c-twist-google-analytics>

        <template if:true={isCurrentSectionAccountCreation}>
            <div class="component is--registration" if:true={registrationFormField}>
                <form class={componentForm}>

                    <div if:true={isGlobalError}>
                        <div class="global-error-message">{form.error}</div>
                    </div>

                    <template if:true={componentConfig.modeInfo.isRegistrationMode}>

                        <h1 class="component__title">{customLabels.Twist_Account_Creation_TitleAccountCreation}</h1>
                        <div class="div-line">

                            <template lwc:if={showLineButton}>
                                <a href={socialMediaProviders.LineLV} class="line_button">
                                <img class="line-icon-svg" src={twistLineLogo} alt="LINE" title="LINE"/>
                                    {customLabels.Twist_Login_Page_Social_Login_Line}
                                </a>
                            </template>


                            <template lwc:if={showLineTWButton}>
                                <a href={socialMediaProviders.LineLVTW} class="line_button">
                                <img class="line-icon-svg" src={twistLineLogo} alt="LINE" title="LINE"/>
                                    {customLabels.Twist_Login_Page_Social_Login_Line}
                                </a>
                            </template>

                            <template lwc:if={showLineTHButton}>
                                <a href={socialMediaProviders.LineLVTH} class="line_button">
                                <img class="line-icon-svg" src={twistLineLogo} alt="LINE" title="LINE"/>
                                    {customLabels.Twist_Login_Page_Social_Login_Line}
                                </a>
                            </template>

                            <template lwc:if={showKakaoButton}>
                            <a href={socialMediaProviders.KakaoLV} class="kakao-button">
                            <img class="kakao-icon-svg" src={twistKakaoLogo} alt="Kakao" title="Kakao"/>
                                {customLabels.Twist_Login_Page_Social_Login_Kakao}
                            </a>
                            </template>

                            <template lwc:if={showGoogleButton}>
                                <a href={socialMediaProviders.GoogleLV} class="google_button">
                                <img class="google-icon-svg" src={twistGoogleLogo} alt="google" title="google"/>
                                    {customLabels.Twist_Login_Page_Social_Login_Google}
                                </a>
                            </template>

                            <template lwc:if={showOrText}>
                                <div class="line-container">
                                    <div class="line"></div>
                                    <p class="line-or-text">{customLabels.Twist_Social_Line_Text_For_Second_Option}</p>
                                    <div class="line"></div>
                                </div>
                            </template>
                        </div>


                        <p class="component__text">{customLabels.Twist_Account_Creation_TextAccountCreation} </p>
                        <p class="component__text">{customLabels.Twist_Account_Creation_SecondTextAccountCreation}
                            <lightning-formatted-text
                            class="form__link"
                            value={customLabels.Twist_Account_Creation_LoginHereLink}
                            onclick={handleClickOnLoginHereLink}>
                            </lightning-formatted-text>
                        </p>
                        <p class="required_field_text">{customLabels.Twist_RequiredFieldsLabel}</p>
                        <form class="components__form">

                            <div class="left">

                                <template if:true={registrationFormField.email}>
                                    <lightning-input
                                        data-id={registrationFormField.email.Field__c}
                                        autocomplete="off"
                                        type="text"
                                        label={customLabels.Twist_Account_Creation_EmailFieldLabel}
                                        value={formData.email}
                                        onblur={handleInputBlur}
                                        required={registrationFormField.email.Is_Required__c}
                                        data-cs-mask
                                        disabled={isEmailDisabled}
                                        aria-invalid={ariaInvalid}>
                                    </lightning-input>
                                </template>

                                <template if:true={registrationFormField.emailconfirmation}>
                                    <lightning-input
                                        data-id={registrationFormField.emailconfirmation.Field__c}
                                        name="confirm"
                                        autocomplete="off"
                                        type="text"
                                        label={customLabels.Twist_Account_Creation_EmailConfirmationFieldLabel}
                                        value=""
                                        required={registrationFormField.emailconfirmation.Is_Required__c}
                                        onpaste={handlePaste}
                                        onblur={handleInputBlur}
                                        class={emailConfirmationClassName}
                                        data-cs-mask
                                        disabled={isLogInModalDisplayed}>
                                    </lightning-input>
                                </template>

                                <template if:true={registrationFormField.password}>

                                    <div class="twist-password-field-container" >
                                        <lightning-input
                                            data-id={registrationFormField.password.Field__c}
                                            autocomplete="off"
                                            type={passwordFieldType}
                                            label={customLabels.Twist_Account_Creation_PasswordFieldLabel}
                                            value=""
                                            required={registrationFormField.password.Is_Required__c}
                                            onchange={handleFormPasswordChange}
                                            onfocus={handleFormPasswordFocus}
                                            onblur={handleInputBlur}
                                            class="eye-icon__wrapper"
                                            data-cs-mask
                                            disabled={isLogInModalDisplayed}
                                            onkeydown={handleTab}>
                                        </lightning-input>
                                        <img class="eye-iconSmall" src={eyeIconSrcPassword} onclick={handleToggleShowPassword} />
                                    </div>

                                    <div if:true={language}>
                                        <c-twist-password-validity-criteria language={language}></c-twist-password-validity-criteria>
                                    </div>

                                </template>
                                <template lwc:if={componentConfig.showKanaFields}>
                                    <template lwc:if={registrationFormField.birthdate}>
                                        <c-date-input-format
                                            date-field={registrationFormField.birthdate}
                                            custom-labels={customLabels}
                                            calendar-date-format={componentConfig.calendarDateFormat}
                                            ongetfieldbirthday={handleInputBlur}
                                            onkeydown={handleTab}>
                                        </c-date-input-format>
                                    </template>
                                </template>
                            </div>

                            <div class="right">
                                <template if:true={registrationFormField.title}>
                                    <div class="hidden-input-logo__wrapper">
                                        <div class={titleFormElementClass}>
                                        <label class="slds-form-element__label" for={registrationFormField.title.Field__c}>
                                            <abbr class="slds-required" title="required" if:true={registrationFormField.title.Is_Required__c}>*</abbr>
                                            {customLabels.Twist_Account_Creation_TitleFieldLabel}
                                        </label>
                                        <div class="slds-form-element__control">
                                            <select
                                            class="slds-select combobox"
                                            data-id={registrationFormField.title.Field__c}
                                            onchange={handleComboboxesChange}
                                            onblur={validateRequiredField}
                                            disabled={isLogInModalDisplayed}
                                            data-cs-mask>
                                            <option value="" disabled selected>{customLabels.Twist_Account_Creation_Title_Placeholder}</option>
                                            <template for:each={componentConfig.titleList} for:item="title">
                                                <option key={title.value} value={title.value}>
                                                    {title.label}
                                                </option>
                                            </template>
                                        </select>
                                        </div>
                                        <div if:true={emptyComboboxFields.title} class="slds-form-element__help">
                                            {customLabels.Twist_Form_FieldCantBeEmpty}
                                        </div>
                                       </div>
                                        <img class="registration-chevron" src={chevronLV} />
                                    </div>
                                </template>

                                <template if:false={componentConfig.showKanaFields}>
                                    <template if:true={registrationFormField.firstname}>
                                        <lightning-input
                                            data-id={registrationFormField.firstname.Field__c}
                                            autocomplete="off"
                                            type="text"
                                            label={customLabels.Twist_Account_Creation_FirstNameFieldLabel}
                                            value={formData.firstname}
                                            pattern={regexNoDigitAndSpecialChars}
                                            onkeypress={handleOnKeyPress}
                                            onblur={handleInputBlur}
                                            required={registrationFormField.firstname.Is_Required__c}
                                            max-length={registrationFormField.firstname.Validation_Max_Length__c}
                                            disabled={isLogInModalDisplayed}
                                            data-cs-mask>
                                        </lightning-input>
                                    </template>
                                </template>

                                <template if:true={registrationFormField.lastname}>
                                    <lightning-input
                                        data-id={registrationFormField.lastname.Field__c}
                                        autocomplete="off"
                                        type="text"
                                        label={customLabels.Twist_Account_Creation_LastNameFieldLabel}
                                        value={formData.lastname}
                                        pattern={regexNoDigitAndSpecialChars}
                                        onkeypress={handleOnKeyPress}
                                        onblur={handleInputBlur}
                                        required={registrationFormField.lastname.Is_Required__c}
                                        max-length={registrationFormField.lastname.Validation_Max_Length__c}
                                        disabled={isLogInModalDisplayed}
                                        data-cs-mask>
                                    </lightning-input>
                                </template>

                                <template lwc:if={componentConfig.showKanaFields}>
                                    <template if:true={registrationFormField.firstname}>
                                        <lightning-input
                                            data-id={registrationFormField.firstname.Field__c}
                                            autocomplete="off"
                                            type="text"
                                            label={customLabels.Twist_Account_Creation_FirstNameFieldLabel}
                                            value={formData.firstname}
                                            pattern={regexNoDigitAndSpecialChars}
                                            onkeypress={handleOnKeyPress}
                                            onblur={handleInputBlur}
                                            required={registrationFormField.firstname.Is_Required__c}
                                            max-length={registrationFormField.firstname.Validation_Max_Length__c}
                                            disabled={isLogInModalDisplayed}
                                            data-cs-mask>
                                        </lightning-input>
                                    </template>
                                </template>


                                 <template lwc:if={registrationFormField.lastname2}>
                                     <lightning-input
                                        data-id={registrationFormField.lastname2.Field__c}
                                        autocomplete="off"
                                        type="text"
                                        label={customLabels.Twist_Account_Creation_LastName2FieldLabel}
                                        value={formData.lastname2}
                                        pattern={regexNoDigitAndSpecialChars}
                                        onkeypress={handleOnKeyPress}
                                        onblur={handleInputBlur}
                                        required={registrationFormField.lastname2.Is_Required__c}
                                        max-length={registrationFormField.lastname2.Validation_Max_Length__c}
                                        disabled={isLogInModalDisplayed}
                                        data-cs-mask>
                                     </lightning-input>
                                 </template>

                                <template lwc:if={registrationFormField.firstname2}>
                                    <lightning-input
                                        data-id={registrationFormField.firstname2.Field__c}
                                        autocomplete="off"
                                        type="text"
                                        label={customLabels.Twist_Account_Creation_FirstName2FieldLabel}
                                        value={formData.firstname2}
                                        pattern={regexNoDigitAndSpecialChars}
                                        onkeypress={handleOnKeyPress}
                                        onblur={handleInputBlur}
                                        required={registrationFormField.firstname2.Is_Required__c}
                                        max-length={registrationFormField.firstname2.Validation_Max_Length__c}
                                        disabled={isLogInModalDisplayed}
                                        data-cs-mask>
                                    </lightning-input>
                                </template>

                                <template lwc:if={showCountryField}>
                                    <div class="hidden-input-logo__wrapper">
                                        <template if:true={componentConfig.showCountryList}>
                                            <div class={countryFormElementClass}>
                                                <label class="slds-form-element__label" for={registrationFormField.country.Field__c}>
                                                    <abbr class="slds-required" title="required" if:true={registrationFormField.country.Is_Required__c}>*</abbr>
                                                    {customLabels.Twist_Account_Creation_CountryFieldLabel}
                                                </label>
                                                <div class="slds-form-element__control">
                                                    <select
                                                    class="slds-select combobox"
                                                    data-id={registrationFormField.country.Field__c}
                                                    onchange={handleComboboxesChange}
                                                    onblur={validateRequiredField}
                                                    disabled={isLogInModalDisplayed}
                                                    onkeydown={handleTab}>
                                                    <template if:true={showCountryPlaceholder}>
                                                        <option value="" disabled selected>{customLabels.Twist_Account_Creation_Country_Placeholder}</option>
                                                    </template>
                                                    <template for:each={countryOptions} for:item="country">
                                                        <option key={country.value} value={country.value} selected={country.selected}>
                                                            {country.label}
                                                        </option>
                                                    </template>
                                                </select>
                                                </div>
                                                <div if:true={emptyComboboxFields.country} class="slds-form-element__help">
                                                    {customLabels.Twist_Form_FieldCantBeEmpty}
                                                </div>
                                            </div>
                                        </template>
                                        <img class="registration-chevron" src={chevronLV} />
                                    </div>
                                </template>
                                <template if:false={componentConfig.showKisaFields}>
                                    <template if:true={registrationFormField.mobile_phone}>
                                        <div class="phone-div">
                                            <template if:true={registrationFormField.calling_code}>
                                                <div class="prefix">
                                                    <lightning-combobox name="prefix"
                                                        data-id={registrationFormField.calling_code.Field__c}
                                                        label={customLabels.Twist_Account_Creation_Mobile_Phone_Label}
                                                        value={formData.calling_code}
                                                        onblur={handleInputBlur}
                                                        onchange={handleComboboxesChange}
                                                        options={componentConfig.showCallingCodeList}
                                                        >
                                                    </lightning-combobox>
                                                </div>
                                            </template>
                                            <div class="phone-number">
                                                <lightning-input
                                                    data-id={registrationFormField.mobile_phone.Field__c}
                                                    value={phoneNumber}
                                                    onblur={handleInputBlur}
                                                    onchange={handlePhoneNumberChange}
                                                    onkeypress={handleKeyPressOnPhone}
                                                    placeholder={phonePlaceholder}
                                                    maxlength={phoneMaxLength}
                                                    autocomplete="off"
                                                    type="tel"
                                                    data-cs-mask
                                                    onkeydown={handleTab}>
                                                </lightning-input>
                                            </div>
                                        </div>
                                        <div lwc:if={isSMSCheckedWithoutPhoneFilled} class="help-text">{customLabels.Twist_Account_Creation_PhoneHelpText}</div>
                                    </template>
                                </template>
                                <template if:false={componentConfig.showKanaFields}>
                                    <template lwc:if={registrationFormField.birthdate}>
                                        <c-date-input-format
                                            date-field={registrationFormField.birthdate}
                                            custom-labels={customLabels}
                                            calendar-date-format={componentConfig.calendarDateFormat}
                                            birthday-help-text={componentConfig.birthdayHelpText}
                                            ongetfieldbirthday={handleInputBlur}
                                            disabled={isLogInModalDisplayed}
                                            onkeydown={handleTab}
                                            data-cs-mask>
                                        </c-date-input-format>
                                    </template>
                                </template>
                            </div>
                        </form>

                        <template if:true={componentConfig.showKisaFields}>
                            <template if:false={koreanAddressFields}>
                                <div class={koreaAddressButton}>
                                    <div class="button-div-form-fields">
                                        <lightning-button
                                            class="kisa-button"
                                            label={customLabels.Twist_Account_Creation_Korea_Address_Button}
                                            onclick={showKoreanAddressFields}>
                                        </lightning-button>
                                    </div>
                                </div>
                            </template>
                        </template>

                        <template if:true={componentConfig.showKisaFields}>
                            <template if:true={koreanAddressFields}>
                                <hr class="border-logo" />
                                <div class="close"><img onclick={hideKoreanAddressFields} src={twistCloseIcon} /></div>
                                <div class="zip-code">
                                    <template if:true={registrationFormField.postal_code}>
                                        <lightning-input
                                            data-id={registrationFormField.postal_code.Field__c}
                                            label={customLabels.Twist_Account_Creation_Postal_Code_Label}
                                            value={formData.postal_code}
                                            onblur={handleInputBlur}
                                            autocomplete="off"
                                            type="text"
                                            max-length="10"
                                            message-when-value-missing={customLabels.Twist_Form_FieldCantBeEmpty}
                                            required={isRequired}
                                            data-cs-mask
                                        >
                                        </lightning-input>
                                    </template>
                                    <div>
                                        <lightning-button
                                            class="btn_zip_code"
                                            label={customLabels.Twist_Account_Creation_Juso_Button}
                                            onclick={handleShowModal}>
                                        </lightning-button>
                                    </div>
                                </div>
                                <p class="component__text">{customLabels.Twist_Account_Creation_Text_Under_Postal_Code_Label}</p>

                                <c-twist-juso-address-search
                                    custom-labels={customLabels}
                                    show-modal-juso={showModalJuso}
                                    onconfirm={handleModalConfirm}>
                                </c-twist-juso-address-search>

                                <div class="components__form">
                                    <div class="left">
                                        <template if:true={registrationFormField.state}>
                                            <lightning-input
                                                data-id={registrationFormField.state.Field__c}
                                                label={customLabels.Twist_Account_Creation_State_Label}
                                                value={formData.state}
                                                onblur={handleInputBlur}
                                                autocomplete="off"
                                                type="text"
                                                message-when-value-missing={customLabels.Twist_Form_FieldCantBeEmpty}
                                                required={isRequired}
                                                data-cs-mask
                                                >
                                            </lightning-input>
                                        </template>
                                        <template if:true={registrationFormField.address1}>
                                            <lightning-input
                                                data-id={registrationFormField.address1.Field__c}
                                                label={customLabels.Twist_Account_Creation_Address1_Label}
                                                value={formData.address1}
                                                onblur={handleInputBlur}
                                                max-length="40"
                                                autocomplete="off"
                                                type="text"
                                                required={isRequired}
                                                message-when-value-missing={customLabels.Twist_Form_FieldCantBeEmpty}
                                                data-cs-mask
                                                >
                                            </lightning-input>
                                        </template>
                                        <template if:true={registrationFormField.address3}>
                                            <lightning-input
                                                data-id={registrationFormField.address3.Field__c}
                                                label={customLabels.Twist_Account_Creation_Address3_Label}
                                                value={formData.address3}
                                                onblur={handleInputBlur}
                                                max-length="40"
                                                autocomplete="off"
                                                type="text"
                                                required={isRequired}
                                                message-when-value-missing={customLabels.Twist_Form_FieldCantBeEmpty}
                                                data-cs-mask
                                                >
                                            </lightning-input>
                                        </template>
                                    </div>
                                    <div class="right">
                                        <template if:true={registrationFormField.city}>
                                            <lightning-input
                                                data-id={registrationFormField.city.Field__c}
                                                label={customLabels.Twist_Account_Creation_City_Label}
                                                value={formData.city}
                                                onblur={handleInputBlur}
                                                autocomplete="off"
                                                type="text"
                                                required={isRequired}
                                                message-when-value-missing={customLabels.Twist_Form_FieldCantBeEmpty}
                                                data-cs-mask
                                            >
                                            </lightning-input>
                                        </template>
                                        <template if:true={registrationFormField.address2}>
                                            <lightning-input
                                                data-id={registrationFormField.address2.Field__c}
                                                label={customLabels.Twist_Account_Creation_Address2_Label}
                                                value={formData.address2}
                                                onblur={handleInputBlur}
                                                max-length="40"
                                                autocomplete="off"
                                                type="text"
                                                required={isRequired}
                                                message-when-value-missing={customLabels.Twist_Form_FieldCantBeEmpty}
                                                data-cs-mask
                                                >
                                            </lightning-input>
                                        </template>
                                        <template if:true={registrationFormField.mobile_phone}>
                                            <div class="phone-div">
                                                <template if:true={registrationFormField.calling_code}>
                                                    <div class="prefix">
                                                        <lightning-combobox name="prefix"
                                                            data-id={registrationFormField.calling_code.Field__c}
                                                            label={customLabels.Twist_Account_Creation_Mobile_Phone_Label}
                                                            onchange={handleComboboxesChange}
                                                            value={formData.calling_code}
                                                            onblur={handleInputBlur}
                                                            options={componentConfig.showCallingCodeList}
                                                            required={isRequired}
                                                            >
                                                        </lightning-combobox>
                                                    </div>
                                                </template>
                                                <div class="phone-number">
                                                    <lightning-input
                                                        data-id={registrationFormField.mobile_phone.Field__c}
                                                        value={phoneNumber}
                                                        placeholder={phonePlaceholder}
                                                        onblur={handleInputBlur}
                                                        onkeypress={handleKeyPressOnPhone}
                                                        onchange={handlePhoneNumberChange}
                                                        autocomplete="off"
                                                        type="tel"
                                                        maxlength={phoneMaxLength}
                                                        required={isRequired}
                                                        message-when-value-missing={customLabels.Twist_Form_FieldCantBeEmpty}
                                                        data-cs-mask>
                                                    </lightning-input>
                                                </div>
                                            </div>
                                        </template>
                                    </div>
                                </div>
                            </template>
                        </template>

                    </template>

                    <template if:true={componentConfig.modeInfo.isPartialActivationMode}>

                        <div class="partialActivationForm">
                            <h2 class="component__title">{customLabels.Twist_Partial_Activation_Form_PartialActivationSubtitle}</h2>
                            <p class="component__text">{customLabels.Twist_Partial_Activation_Form_PartialActivationYourEmailText} <span data-cs-mask>{componentConfig.identifier}</span></p>
                            <p class="component__text">{customLabels.Twist_Activation_Email_Section_Description}</p>
                            <form class="partial-form">

                                <template if:true={registrationFormField.password}>

                                    <div class="twist-password-field-container" >
                                        <lightning-input
                                            data-id={registrationFormField.password.Field__c}
                                            autocomplete="off"
                                            type={passwordFieldType}
                                            label={customLabels.Twist_Account_Creation_PasswordFieldLabel}
                                            required={registrationFormField.password.Is_Required__c}
                                            onchange={handleFormPasswordChange}
                                            onfocus={handleFormPasswordFocus}
                                            onblur={handleInputBlur}
                                            class="eye-icon__wrapper"
                                            data-cs-mask>
                                        </lightning-input>
                                        <img class="eye-iconSmall" src={eyeIconSrcPassword} onclick={handleToggleShowPassword} />
                                    </div>

                                    <div if:true={language}>
                                        <c-twist-password-validity-criteria language={language}></c-twist-password-validity-criteria>
                                    </div>
                                </template>

                                <template if:true={registrationFormField.passwordconfirmation}>
                                    <div class="twist-password-field-container" >
                                        <lightning-input
                                            data-id={registrationFormField.passwordconfirmation.Field__c}
                                            type={confirmPasswordFieldType}
                                            label={customLabels.Twist_Reset_Password_Form_ConfirmPasswordFieldLabel}
                                            required={registrationFormField.passwordconfirmation.Is_Required__c}
                                            onblur={handleInputBlur}
                                            data-cs-mask>
                                        </lightning-input>
                                        <img class="eye-iconSmall" src={eyeIconSrcConfirmPassword} onclick={handleToggleShowConfirmPassword} />
                                    </div>
                                </template>
                            </form>
                        </div>

                    </template>

                   /* <template if:true={registrationFormField.newsletter_agreement}>
                        <template if:true={registrationFormField.newsletterPersonalDataConsent}>
                            <div class="privacy-policy">
                                <lightning-input
                                    label=""
                                    data-id={registrationFormField.newsletterPersonalDataConsent.Field__c}
                                    value={formData.newsletterPersonalDataConsent}
                                    onchange={handleCheckboxChange}
                                    autocomplete="off"
                                    type="checkbox"
                                    required={registrationFormField.newsletterPersonalDataConsent.Is_Required__c}
                                    data-cs-mask
                                    >
                                </lightning-input>
                                <p class={containerClassName}>
                                    {customLabels.Twist_Account_Creation_Newsletter_Personal_Data_Consent_Part_One}&nbsp;
                                    <span class="newsletter_data_consent">{customLabels.Twist_Account_Creation_Newsletter_Personal_Data_Consent_Part_Two}</span>&nbsp;
                                    {customLabels.Twist_Account_Creation_Newsletter_Personal_Data_Consent_Part_Tree}&nbsp;
                                    <span class="newsletter_data_consent">{customLabels.Twist_Account_Creation_Newsletter_Personal_Data_Consent_Part_Four}</span>&nbsp;
                                    {customLabels.Twist_Account_Creation_Newsletter_Personal_Data_Consent_Part_Five}
                                </p>
                            </div>
                            <div class="privacy-policy">
                                <lightning-input
                                    label=""
                                    data-id={registrationFormField.newsletter_agreement.Field__c}
                                    value={formData.newsletter_agreement}
                                    onchange={handleCheckboxChange}
                                    autocomplete="off"
                                    type="checkbox"
                                    required={registrationFormField.newsletter_agreement.Is_Required__c}
                                    data-cs-mask
                                >
                                </lightning-input>
                                <p class={containerClassName}>{customLabels.Twist_Account_Creation_CheckFieldLabel_Newsletter_Korea}</p>
                            </div>
                            <p class={containerClassName}>
                                {customLabels.Twist_Account_Creation_CheckFieldLabel_Newsletter_Korea_Text}&nbsp;
                                <lightning-formatted-text
                                    class="form__link_privacy_policy"
                                    value={customLabels.Twist_Account_Creation_CheckFieldLabel_Newsletter_Korea_Text_Two}
                                    onclick={handleTermConditionClick}>
                                </lightning-formatted-text>
                            </p>
                        </template>
                    </template>

                    <template if:false={isGlobalConsentActivated}>
                        <template if:true={registrationFormField.newsletter_agreement}>
                            <template if:false={registrationFormField.newsletterPersonalDataConsent}>
                                <template if:false={registrationFormField.privacy_policy}>
                                    <template if:true={registrationFormField.newsletter_agreement.Default_Value__c}>
                                        <div class="privacy-policy">
                                            <lightning-input if:true={registrationFormField.newsletter_agreement}
                                                data-id={registrationFormField.newsletter_agreement.Field__c}
                                                type="checkbox"
                                                class="checkbox"
                                                label=""
                                                autocomplete="off"
                                                onchange={handleCheckboxChange}
                                                required={registrationFormField.newsletter_agreement.Is_Required__c}
                                                value={formData.newsletter_agreement}
                                                checked>
                                            </lightning-input>
                                            <p class={containerClassName}>
                                                {customLabels.Twist_Account_Creation_CheckFieldLabel}&nbsp;
                                                <lightning-formatted-text
                                                    class="form__link_privacy_policy"
                                                    value={customLabels.Twist_Account_Creation_CheckFieldLinkLabel}
                                                    onclick={handleTermConditionClick}>
                                                </lightning-formatted-text>
                                                .
                                            </p>
                                        </div>
                                    </template>
                                    <template if:false={registrationFormField.newsletter_agreement.Default_Value__c}>
                                        <div class="privacy-policy">
                                            <lightning-input if:true={registrationFormField.newsletter_agreement}
                                                data-id={registrationFormField.newsletter_agreement.Field__c}
                                                type="checkbox"
                                                class="checkbox"
                                                label=""
                                                autocomplete="off"
                                                onchange={handleCheckboxChange}
                                                required={registrationFormField.newsletter_agreement.Is_Required__c}
                                                value={formData.newsletter_agreement}>
                                            </lightning-input>
                                            <p class={containerClassName}>
                                                {customLabels.Twist_Account_Creation_CheckFieldLabel}&nbsp;
                                                <lightning-formatted-text
                                                    class="form__link_privacy_policy"
                                                    value={customLabels.Twist_Account_Creation_CheckFieldLinkLabel}
                                                    onclick={handleTermConditionClick}>
                                                </lightning-formatted-text>
                                                .
                                            </p>
                                        </div>
                                    </template>
                                </template>
                            </template>
                        </template>
                    </template>

                <template lwc:if={isGlobalConsentActivated}>
                    <div class={termsGlobalClassName}>
                        <!-- Global Consent Checkbox -->
                        <lightning-input
                            type="checkbox"
                            class="checkbox"
                            label=""
                            autocomplete="off"
                            required={registrationFormField.newsletter_agreement.Is_Required__c}
                            onchange={handleGlobalConsentChange}
                            checked={isGlobalConsentChecked}>
                        </lightning-input>
                        <template lwc:if={registrationFormField.privacy_policy}>
                            <p class={containerClassName}>{customLabels.Twist_Account_Creation_CheckFieldLabel_GCM_SmsConsent_Without_Link}&nbsp;</p>
                        </template>
                        <template lwc:else>
                            <p class={containerClassName}>
                                {customLabels.Twist_Account_Creation_CheckFieldLabel_GCM_SmsConsent}&nbsp;
                                <lightning-formatted-text
                                    class="form__link_privacy_policy"
                                    value={customLabels.Twist_Account_Creation_CheckFieldLinkLabel}
                                    onclick={handleTermConditionClick}>
                                </lightning-formatted-text>
                                .
                            </p>
                        </template>
                    </div>  
                        
                    <!-- Channels Section -->
                    <template lwc:if={isGlobalConsentChecked}>
                        <div class="channels-section-wrapper">
                            <p class="channels-section-text">{customLabels.Twist_Account_Creation_CheckFieldLabel_Preferences}&nbsp;</p>
                            <div class="subscription-preferences">
                                <!-- Email Consent -->
                                <lightning-input
                                    data-id={registrationFormField.newsletter_agreement.Field__c}
                                    type="checkbox"
                                    class="global-consent-checkbox"
                                    label={customLabels.Twist_Account_Creation_CheckFieldLabel_Email}
                                    autocomplete="off"
                                    onchange={handleCheckboxChange}
                                    required={registrationFormField.newsletter_agreement.Is_Required__c}
                                    value={formData.newsletter_agreement}
                                    checked={isEmailConsentChecked}>
                                </lightning-input>
                                <!-- SMS Consent -->
                                <template lwc:if={showSmsConsent}>
                                    <lightning-input
                                    data-id={registrationFormField.SMS_agreement.Field__c}
                                    type="checkbox"
                                    class="global-consent-checkbox"
                                    label={customLabels.Twist_Account_Creation_CheckFieldLabel_SMS}
                                    autocomplete="off"
                                    onchange={handleCheckboxChange}
                                    required={registrationFormField.SMS_agreement.Is_Required__c}
                                    value={formData.SMS_agreement}
                                    checked={isSMSConsentChecked}>
                                </lightning-input>
                                </template>
                                <!-- GCM Consent -->
                                <template lwc:if={showGoogleCustomerMatchConsent}>
                                    <div class="gcm-consent-terms">
                                        <lightning-input
                                        data-id={registrationFormField.GCM_agreement.Field__c}
                                        type="checkbox"
                                        class="global-consent-checkbox"
                                        label=""
                                        autocomplete="off"
                                        onchange={handleCheckboxChange}
                                        required={registrationFormField.GCM_agreement.Is_Required__c}
                                        value={formData.GCM_agreement}
                                        checked={isGCMConsentChecked}>
                                        </lightning-input>
                                        <p class="channels-section-text gcm-consent-text">
                                            {customLabels.Twist_Account_Creation_CheckFieldLabel_GCM}&nbsp;
                                            <lightning-formatted-text
                                            class="form__link_privacy_policy"
                                            value={customLabels.Twist_Account_Creation_CheckFieldLinkLabel_GCM}
                                            onclick={handleClickOnGCMModalLink}>
                                            </lightning-formatted-text>
                                        </p>
                                    </div>
                                </template>
                            </div>
                        </div>

                    </template>   
                </template>

                <template lwc:if={registrationFormField.privacy_policy}>
                    <div class="privacy-policy">
                        <lightning-input lwc:if={registrationFormField.privacy_policy}
                            data-id={registrationFormField.privacy_policy.Field__c}
                            type="checkbox"
                            class="checkbox"
                            label=""
                            autocomplete="off"
                            onchange={handleCheckboxChangePrivacyPolicy}
                            value={formData.privacy_policy}>
                        </lightning-input>
                        <p class={containerClassName}>
                            {customLabels.Twist_Account_Creation_CheckFieldLabel_Privacy_Policy}&nbsp;
                            <lightning-formatted-text
                                class="form__link_privacy_policy"
                                value={customLabels.Twist_Account_Creation_CheckFieldLinkLabel}
                                onclick={handleTermConditionClick}>
                                </lightning-formatted-text>
                            . <span>*</span>
                        </p>
                    </div>
                </template>

                <template if:true={componentConfig.modeInfo.doNeedVerificationCode}>
                    <div class="button__wrapper">
                        <div class="button__container">
                            <lightning-button
                                class="continue__button"
                                label={customLabels.Twist_Account_Creation_Form_ContinueButtonLabel}
                                onclick={handleClickOnContinueButton} >
                            </lightning-button>

                            <p class="under_text">{customLabels.Twist_Account_Creation_EndTextAccountCreation}</p>
                        </div>
                    </div>
                </template>

                <template if:false={componentConfig.modeInfo.doNeedVerificationCode}>
                    <div class="button__container">
                        <lightning-button
                            class="continue__button"
                            label={customLabels.Twist_Account_Creation_Form_ContinueButtonLabel}
                            onclick={handleClickOnContinueWithoutActivationCodeButton}>
                        </lightning-button>

                        <p class="under_text">
                            {customLabels.Twist_Account_Creation_ByCreatingText}&nbsp;
                            <lightning-formatted-text
                                class="form__link_terms_conditions"
                                value={customLabels.Twist_Account_Creation_TermAndConditionsLink}
                                onclick={handleTermConditionClick}>
                            </lightning-formatted-text>
                        </p>
                    </div>
                </template>
                </form>
            </div>
        </template>

        <template if:true={isKisaFields}>
            <div class="component__form">
                <c-twist-kisa-fields
                    custom-labels={customLabels}
                    onshownextsection={handleClickSendKisaCheckboxes}
                    onkisacheckboxchange={handleKisaCheckboxChange}
                    kisa-one={componentConfig.form.kisa_one}
                    kisa-two={componentConfig.form.lvTermsAndUseConsent}
                    kisa-tree={componentConfig.form.mainPersonalDataConsent}
                    kisa-four={componentConfig.form.additionalPersonalDataConsent}
                    riskified-kisa={componentConfig.form.thirdPartiesPersonalDataConsent}
                    kisa-five={componentConfig.form.promotionPersonalDataConsent}
                    kisa-six={componentConfig.form.requiredAgeConsent}
                    >
                </c-twist-kisa-fields>
            </div>
        </template>

        <template if:true={isCurrentSectionActivateYourAccount}>
            <div class="component">
                <form class="form">

                    <h1 class="component__title">{customLabels.Twist_Account_Creation_TitleActivateYourAccount}</h1>
                    <p class="component__text">
                        {customLabels.Twist_Account_Creation_ActivationCodeText}<br/>
                        <span data-cs-mask>{formData.email} </span>
                        {customLabels.Twist_Account_Creation_ActivationCodeSecondeLineText}
                    </p>
                    <form class="component__form">
                        <lightning-input
                            data-id="activationCode"
                            class="activationCodeCss"
                            name="accountCode"
                            type="text"
                            label={customLabels.Twist_Account_Creation_AccountCodeFieldLabel}
                            onkeypress={handleKeypressOnActivationCode}
                            onchange={handleCodeChange}
                            required
                            data-cs-mask>
                        </lightning-input>

                        <div class="form__text">
                            <lightning-button data-id="resendCode" class="form__link" label={customLabels.Twist_Account_Creation_SendAgainLink} onclick={handleResendVerificationCode}></lightning-button>
                            <div class="newCodeGeneratedTextCss">{newCodeGeneratedMessage}</div>
                        </div>

                        <div class="button__container">
                            <lightning-button
                                class="continue__button"
                                label={customLabels.Twist_Account_Creation_Form_ActivateButtonLabel}
                                onclick={handleClickOnActivateAccountButton}>
                            </lightning-button>

                            <p class="under_text">
                                {customLabels.Twist_Account_Creation_ByCreatingText}&nbsp;
                                <lightning-formatted-text
                                    class="form__link_terms_conditions"
                                    value={customLabels.Twist_Account_Creation_TermAndConditionsLink}
                                    onclick={handleTermConditionClick}>
                                </lightning-formatted-text>
                            </p>
                        </div>

                    </form>

                </form>
            </div>
        </template>

        <template if:true={isCurrentSectionConfirmationMessage}>
            <c-twist-account-confirmation
                twist-logo={twistLogoLV}
                language={language}
                autodata={autodata}
                text-to-display={customLabels.Twist_Account_Creation_ConfirmationText}
                activation-code={verificationCode}
                account-creation-form={formData}
                query-params={queryParams}
                social-params={socialParams}
                pass-key={passKey}>
            </c-twist-account-confirmation>
        </template>

        <c-twist-login-modal
            show-modal={isLogInModalDisplayed}
            language={language}
            email={formData.email}
            social-params={socialParams}
            o-query-params={oQueryParams}
            password-maxlength={componentConfig.passwordMaxlength}
            forgot-password-url={componentConfig.forgotPasswordUrl}
            onclickforgotpassword={handleClickOnForgotPasswordLink}
            onclicklogin={handleLoginFromPopup}>
        </c-twist-login-modal >

        <template if:true={showModalGCM}>
            <c-twist-google-customer-match-modal 
                content={customLabels.Twist_Account_Creation_CheckFieldModalContent_GCM} 
                onclose={handleGCMModalClose}>
            </c-twist-google-customer-match-modal>
        </template>
        
    </div>

</template>*/

}