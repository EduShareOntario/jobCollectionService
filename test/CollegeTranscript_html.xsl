<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
                xmlns:ct="urn:org:pesc:message:CollegeTranscript:v1.3.0">
    <!--ibah   10-Aug-2015 PR-  000288  RO - Course Exemption Project - eTMS XML Transcript (STUVIEW Web Display) -->
    <xsl:variable name="decfmt">####0.00</xsl:variable>

    <xsl:template match="ct:CollegeTranscript">
        <HTML>
            <HEAD>
                <STYLE TYPE="text/css">
                    body {
                    background: none;
                    font-size : 10px;
                    font-family : Verdana,Arial,Helvetica,sans-serif;
                    }
                    #content {
                    max-width : 960px;
                    float : left;
                    margin : 3px;
                    }
                    #content_title {
                    font-weight : bold;
                    font-size : 11px;
                    margin-bottom : 2px ;
                    min-width : 960px;
                    float : left;
                    }

                    .section {
                    float : left;
                    border : 1px solid black;
                    width : 450px;
                    padding : 2px;
                    margin: 0 5px 3px 0;
                    min-height : 300px;
                    }

                    .gbc_section {
                    width: 910px;
                    min-height: 17px;
                    }

                    .gbc_section table {
                    float :  left ;
                    border-collapse:collapse;
                    font-size : 110%;
                    }

                    .label5 {
                    font-size: 16px;
                    font-weight: bold;
                    }
                    .onepxsolid{
                    border:1px solid black;
                    min-width : 75px;
                    padding : 2px 3px 2px 3px;
                    }

                    .session2 {
                    min-height : 100px;
                    }
                    .academicsession{
                    min-height : 145px;
                    border : none;
                    padding-left : 2px;
                    }
                    .academic_title {
                    background : #0065a4;
                    color : #ffffff;
                    font-weight : bold ;
                    padding : 2px 0 2px 2px;
                    }

                    .section_title{
                    font-weight : bold;
                    }
                    .clearleft {
                    clear : left;
                    }

                    table {
                    background: none;
                    font-size : 10px;
                    font-family : Verdana,Arial,Helvetica,sans-serif;
                    padding :0;
                    margin :0;
                    float : left;
                    }
                    td {
                    vertical-align : top;
                    }
                    TABLE TD.label1 {
                    width : 150px;
                    }
                    TABLE TD.label2 {
                    width : 130px;
                    }
                    TABLE TD.label0 {
                    font-weight : bold;
                    }


                    TABLE TD.ddheader {
                    background-color: #CCC;
                    color: black;
                    font-family: Verdana,Arial Narrow,  helvetica, sans-serif;
                    font-weight: normal;
                    font-size: 85%;
                    font-style: normal;
                    text-align: left;
                    vertical-align: top;
                    }
                    TABLE TH.ddheader {
                    background-color: #CCC;
                    color: black;
                    font-family: Verdana,Arial Narrow,  helvetica, sans-serif;
                    font-weight: bold;
                    font-size: 85%;
                    font-style: normal;
                    text-align: left;
                    vertical-align: top;
                    }
                    TABLE TH.subject {
                    height : 13px;
                    width : 46px;
                    }
                    TABLE TH.Course {
                    height : 13px;
                    width : 35px;
                    }
                    TABLE TH.title {
                    height : 13px;
                    width : 188px;
                    }
                    TABLE TH.grade {
                    height : 13px;
                    width : 32px;
                    }
                    TABLE TH.creditearned {
                    height : 13px;
                    width : 68px;
                    }
                    TABLE TH.quality {
                    height : 13px;
                    width : 54px;
                    }
                    TABLE TH.GPAType {
                    height : 13px;
                    width : 60px;
                    }
                    TABLE TH.GPAhours {
                    height : 13px;
                    width : 53px;
                    }
                    TABLE TH.GPA{
                    height : 13px;
                    width : 25px;
                    }
                    TABLE TH.Attempted {
                    height : 13px;
                    width : 55px;
                    }


                    .print-friendly  {
                    page-break-inside: avoid;
                    }

                </STYLE>
            </HEAD>
            <BODY>
                <xsl:template match="TransmissionData">
                    <xsl:value-of select="DocumentID"/>
                </xsl:template>

                <div id="content">
                    <!--<xsl:apply-templates select="GBCTranscript/GBCSTUDENT"/>-->
                    <div id="content_title">Student Transcript</div>
                    <xsl:apply-templates select="TransmissionData"/>
                    <xsl:apply-templates select="Student"/>
                    <div class="clearleft"></div>
                    <!--<xsl:apply-templates select="GBCTranscript/GBCSTUDENT"/>-->
                </div>
            </BODY>
        </HTML>
    </xsl:template>

    <xsl:template match="GBCTranscript/GBCSTUDENT">
        <div class="section gbc_section">
            <xsl:choose>
                <xsl:when test="(ERROR)">
                    <table><tr>
                        <td><xsl:value-of select="ERROR"/></td>
                    </tr></table>
                </xsl:when>
                <xsl:when test="(PIDM)">
                    <table><tr>
                        <td class="label5" >BANNER ID:</td><td class="label5" ><xsl:value-of select="ID"/></td ><td >&#160;</td>
                        <td class="label5" >OCAS ID:</td><td class="label5"><xsl:value-of select="OCAS_ID"/></td><td >&#160;</td>
                        <td class="label5" >Name:</td><td class="label5"><xsl:value-of select="LAST_NAME"/>, <xsl:value-of select="FIRST_NAME"/></td><td >&#160;</td><td >&#160;</td>
                    </tr></table>
                    <xsl:if test="(PROGRAM_LIST)">
                        <table>
                            <tr><td class="label0" >Applied Program(s):</td><td >&#160;</td></tr>
                        </table>
                        <table>
                            <xsl:for-each select="PROGRAM_LIST/PROGRAM">
                                <tr >
                                    <td><xsl:value-of select="PROG_CODE"/>&#160;</td>
                                    <td><xsl:value-of select="PROG_NAME"/>&#160;</td>
                                    <td><xsl:value-of select="TERM_CODE"/>&#160;</td>
                                </tr>
                            </xsl:for-each>
                        </table>
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise> </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>

    <xsl:template match="GBCTranscript/xml-fragment">
        <xsl:apply-templates select="TransmissionData"/>
        <xsl:apply-templates select="Student"/>
    </xsl:template>

    <xsl:template match="TransmissionData">
        <div class="section">
            <div class="section_title">Transmission Data</div>
            <table>
                <tr><td class="label1">Document ID: </td> <td><xsl:value-of select="DocumentID"/></td></tr>
                <tr><td class="label1">Document Creation: </td><td><xsl:value-of select="CreatedDateTime"/></td></tr>
                <tr><td class="label1">Document Type: </td><td><xsl:value-of select="DocumentTypeCode"/></td></tr>
                <tr><td class="label1">Transmission Type: </td><td><xsl:value-of select="TransmissionType"/></td></tr>
                <tr><td class="label1">Process Code: </td><td><xsl:value-of select="DocumentProcessCode"/></td></tr>
                <tr><td class="label1">Complete Code: </td> <td><xsl:value-of select="DocumentCompleteCode"/></td></tr>
                <tr><td class="label1">Request Tracking ID: </td> <td><xsl:value-of select="RequestTrackingID"/></td></tr>
                <tr><td colspan="4"><xsl:value-of select="NoteMessage"/></td></tr>
                <tr> <td colspan="4"><b>Source Organisation</b></td></tr>
                <tr><td class="label1">CSIS - Name: </td><td>
                    <xsl:choose>
                        <xsl:when test="(Source/Organization/USIS)"><xsl:value-of select="Source/Organization/USIS"/></xsl:when>
                        <xsl:when test="(Source/Organization/CSIS)"><xsl:value-of select="Source/Organization/CSIS"/></xsl:when>
                        <xsl:otherwise> </xsl:otherwise>
                    </xsl:choose>
                    &#45;&#160;<xsl:value-of select="Source/Organization/OrganizationName"/>
                </td></tr>
                <tr><td class="label1">Phone: </td><td><xsl:if test="(Source/Organization/Contacts/Phone/AreaCityCode)">
                    &#40;<xsl:value-of select="Source/Organization/Contacts/Phone/AreaCityCode"/>&#41;&#160;
                </xsl:if>
                    <xsl:value-of select="Source/Organization/Contacts/Phone/PhoneNumber"/>&#160;
                    <xsl:if test="(Source/Organization/Contacts/Phone/PhoneNumberExtension)">
                        Ext: <xsl:value-of select="Source/Organization/Contacts/Phone/PhoneNumberExtension"/>
                    </xsl:if>
                </td></tr>
                <tr><td class="label1">Address: </td><td>
                    <xsl:for-each select="Source/Organization/Contacts/Address/AddressLine"><xsl:value-of select="."/> &#45; </xsl:for-each>
                    <xsl:value-of select="Source/Organization/Contacts/Address/City"/>&#160;
                    <xsl:value-of select="Source/Organization/Contacts/Address/StateProvinceCode"/>&#160;
                    <xsl:value-of select="Source/Organization/Contacts/Address/PostalCode"/>&#160;</td></tr>
                <tr> <td colspan="4"><b>Destination Organisation</b></td></tr>
                <tr><td class="label1">CSIS - Name: </td><td>
                    <xsl:choose>
                        <xsl:when test="(Destination/Organization/USIS)"><xsl:value-of select="Destination/Organization/USIS"/></xsl:when>
                        <xsl:when test="(Destination/Organization/CSIS)"><xsl:value-of select="Destination/Organization/CSIS"/></xsl:when>
                        <xsl:otherwise> </xsl:otherwise>
                    </xsl:choose>
                    &#45;&#160;<xsl:value-of select="Destination/Organization/OrganizationName"/>
                </td></tr>
                <tr><td class="label1">Phone: </td><td>&#40;<xsl:value-of select="Destination/Organization/Contacts/Phone/AreaCityCode"/>&#41;&#160;
                    <xsl:value-of select="Destination/Organization/Contacts/Phone/PhoneNumber"/>&#160;
                </td></tr>
                <tr><td class="label1">Address: </td><td>
                    <xsl:for-each select="Destination/Organization/Contacts/Address/AddressLine"><xsl:value-of select="."/> &#45; </xsl:for-each>
                    <xsl:value-of select="Destination/Organization/Contacts/Address/City"/>&#160;
                    <xsl:value-of select="Destination/Organization/Contacts/Address/StateProvinceCode"/>&#160;
                    <xsl:value-of select="Destination/Organization/Contacts/Address/PostalCode"/>&#160;</td></tr>
            </table>
        </div>
    </xsl:template>

    <xsl:template match="Student">
        <xsl:apply-templates select="Person"/>
        <xsl:apply-templates select="AcademicRecord"/>
    </xsl:template>

    <xsl:template match="Person">
        <div class="section">
            <div class="section_title">Student Information</div>
            <table>
                <tr><td class="label2" colspan="4">Incoming Institution Assigned Student ID: </td><td ><xsl:value-of select="SchoolAssignedPersonID"/></td><td>&#160;</td>
                </tr>
                <tr>
                    <td class="label2"  colspan="4">OCAS Student ID: </td><td><xsl:value-of select="AgencyAssignedID"/></td>
                </tr>
                <tr>
                    <td class="label2">Last name: </td><td><xsl:value-of select="Name/LastName"/></td><td>&#160;</td>
                    <td class="label2">First name: </td><td><xsl:value-of select="Name/FirstName"/></td>
                </tr>
                <tr>
                    <td class="label2">Middle Name: </td><td><xsl:value-of select="Name/MiddleName"/></td><td>&#160;</td>
                    <td class="label2">Prefix: </td><td><xsl:value-of select="Name/NamePrefix"/></td>
                </tr>
                <tr>
                    <td class="label2">Gender: </td><td><xsl:value-of select="Gender/GenderCode"/></td>
                </tr>
                <tr>
                    <td class="label2">Date of Birth: </td><td><xsl:value-of select="Birth/BirthDate"/></td><td>&#160;</td>
                    <td class="label2">Day of Birth : </td><td><xsl:value-of select="Birth/Birthday"/></td>
                </tr>
                <tr><td class="label2">Composite Name: </td><td> <xsl:value-of select="CompositeName"/> </td><td>&#160;</td>
                    <td class="label2">Alternate Name: </td><td><xsl:value-of select="Name/AlternateName"/></td>
                </tr>
                <tr><td class="label2">Email: </td><td colspan="4"><xsl:value-of select="Contacts/Email/EmailAddress"/></td></tr>
                <tr><td class="label2">High School: </td><td colspan="4"><xsl:value-of select="HighSchool/OrganizationName"/></td></tr>
                <tr><td class="label2">Address: </td><td colspan="4">
                    <xsl:for-each select="Contacts/Address/AddressLine"><xsl:value-of select="."/> &#45; </xsl:for-each>
                    <xsl:value-of select="Contacts/Address/City"/>&#160;
                    <xsl:value-of select="Contacts/Address/StateProvinceCode"/>&#160;
                    <xsl:value-of select="Contacts/Address/PostalCode"/>
                </td></tr>
                <tr><td class="label2" colspan="5">Student Achievement: </td></tr>
                <tr><td colspan="5">
                    <xsl:for-each select="../AcademicRecord/AdditionalStudentAchievements/NoteMessage"><xsl:value-of select="."/><br/> </xsl:for-each>
                </td></tr>
            </table>
        </div>
    </xsl:template>

    <xsl:template match="AcademicRecord">
        <div id="content_title">Academic Sessions</div>
        <xsl:for-each select="AcademicSession">
            <xsl:sort select="AcademicSessionDetail/SessionType" order="descending"/> <!-- order by Term code desc -->
            <xsl:if test="position() mod 2 = 1"> <!-- float left every 2 sections -->
                <div class="clearleft"></div>
            </xsl:if>
            <div class="section academicsession print-friendly">
                <div class="academic_title"><xsl:value-of select="AcademicSessionDetail/SessionName"/></div>
                <table>
                    <xsl:if test="(AcademicProgram/AcademicProgramName)">
                        <tr><td>Program: </td><td colspan="6">
                            <xsl:if test="(AcademicProgram/ProgramSecondarySchoolCode)"><xsl:value-of select="AcademicProgram/ProgramSecondarySchoolCode"/>&#160;</xsl:if>
                            <xsl:value-of select="AcademicProgram/AcademicProgramName"/></td>
                        </tr>
                    </xsl:if>
                    <tr><td width="100px">Session Type: </td><td width="80px"><xsl:value-of select="AcademicSessionDetail/SessionType"/></td><td>&#160;</td>
                        <td width="80px">Term Code: </td><td width="80px"><xsl:value-of select="AcademicSessionDetail/SessionDesignator"/></td>
                    </tr>
                    <tr><td>Begin Date: </td><td><xsl:value-of select="AcademicSessionDetail/SessionBeginDate"/></td><td>&#160;</td>
                        <td>End Date: </td><td><xsl:value-of select="AcademicSessionDetail/SessionEndDate"/></td>
                    </tr>
                    <xsl:if test="(AcademicAward)">
                        <tr><td>Academic Award: </td><td colspan="7"><xsl:value-of select="AcademicAward/AcademicAwardTitle"/> </td></tr>
                        <tr><td>Award Level: </td><td><xsl:value-of select="AcademicAward/AcademicAwardLevel"/></td><td>&#160;</td>
                            <td>Award Date: </td><td><xsl:value-of select="AcademicAward/AcademicAwardDate"/></td>
                        </tr>
                        <tr><td>Award Program: </td>
                            <td colspan="6"><xsl:value-of select="AcademicAward/AcademicAwardProgram/AcademicProgramType"/>&#160;<xsl:value-of select="AcademicAward/AcademicAwardProgram/AcademicProgramName"/></td>
                        </tr>
                    </xsl:if>
                    <xsl:if test="(NoteMessage)">
                        <tr><td colspan="7">
                            <xsl:for-each select="NoteMessage"><xsl:value-of select="."/><br/> </xsl:for-each>
                        </td></tr>
                    </xsl:if>
                </table>
                <table>
                    <TR>
                        <TH CLASS="ddheader subject" scope="col" >Subject</TH>
                        <TH CLASS="ddheader course" scope="col" >Course</TH>
                        <TH COLSPAN="6" CLASS="ddheader title" scope="col" >Title</TH>
                        <TH CLASS="ddheader grade" scope="col" >Grade</TH>
                        <TH CLASS="ddheader creditearned" scope="col" >Credit Earned</TH>
                        <TH CLASS="ddheader quality" scope="col" >Quality Pts</TH>
                    </TR>
                    <xsl:choose>
                        <xsl:when test="(Course)">
                            <xsl:for-each select="Course">
                                <tr>
                                    <TD CLASS="dddefault" ><xsl:value-of select="CourseSubjectAbbreviation"/></TD>
                                    <TD CLASS="dddefault" ><xsl:value-of select="CourseNumber"/></TD>
                                    <TD CLASS="dddefault" COLSPAN="6" ><xsl:value-of select="CourseTitle"/></TD>
                                    <TD CLASS="dddefault"  ><xsl:value-of select="CourseAcademicGrade"/></TD>
                                    <TD CLASS="dddefault" align="right">
                                        <xsl:choose>
                                            <xsl:when test="(CourseCreditEarned)"><xsl:value-of select="format-number(CourseCreditEarned,$decfmt)"/></xsl:when>
                                        </xsl:choose>
                                    </TD>
                                    <TD CLASS="dddefault" align="right">
                                        <xsl:choose>
                                            <xsl:when test="(CourseQualityPointsEarned)"><xsl:value-of select="format-number(CourseQualityPointsEarned,$decfmt)"/></xsl:when>
                                        </xsl:choose>
                                    </TD>
                                </tr>
                                <xsl:if test="(NoteMessage)">
                                    <tr><td CLASS="dddefault" COLSPAN="11">
                                        <xsl:for-each select="NoteMessage"><xsl:value-of select="."/><br/> </xsl:for-each>
                                    </td></tr>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise>
                            <tr>
                                <TD CLASS="dddefault" >&#160;</TD>
                                <TD CLASS="dddefault" >&#160;</TD>
                                <TD CLASS="dddefault" COLSPAN="6" >&#160;</TD>
                                <TD CLASS="dddefault" >&#160;</TD>
                                <TD CLASS="dddefault" >&#160;</TD>
                                <TD CLASS="dddefault" >&#160;</TD>
                            </tr>
                        </xsl:otherwise>
                    </xsl:choose>
                </table>
                <xsl:if test="(AcademicSummary)">
                    <table>
                        <tr><td>Academic Summary Type: </td><td><xsl:value-of select="AcademicSummary/AcademicSummaryType"/> </td></tr>
                        <tr><td>Academic Summary Level: </td><td><xsl:value-of select="AcademicSummary/AcademicSummaryLevel"/></td></tr>
                    </table>
                    <table>
                        <TR>
                            <TH CLASS="ddheader GPAType" scope="col" >Type</TH>
                            <TH CLASS="ddheader GPAhours" scope="col" >GPA Hours</TH>
                            <TH CLASS="ddheader GPA" scope="col" >GPA</TH>
                            <TH  CLASS="ddheader Attempted" scope="col" >Attempted</TH>
                            <TH CLASS="ddheader creditearned" scope="col" >Earned</TH>
                            <TH CLASS="ddheader quality" scope="col" >Quality Pts</TH>
                        </TR>
                        <xsl:choose>
                            <xsl:when test="(AcademicSummary/GPA)">
                                <xsl:for-each select="AcademicSummary/GPA">
                                    <TR>
                                        <TD CLASS="dddefault" ><xsl:value-of select="CreditUnit"/></TD>
                                        <TD CLASS="dddefault" align="right" ><xsl:value-of select="CreditHoursforGPA"/></TD>
                                        <TD CLASS="dddefault" align="right" ><xsl:value-of select="GradePointAverage"/></TD>
                                        <TD CLASS="dddefault" align="right" >
                                            <xsl:choose>
                                                <xsl:when test="(CreditHoursAttempted)"><xsl:value-of select="format-number(CreditHoursAttempted,$decfmt)"/></xsl:when>
                                            </xsl:choose>
                                        </TD>
                                        <TD CLASS="dddefault" align="right">
                                            <xsl:choose>
                                                <xsl:when test="(CreditHoursEarned)"><xsl:value-of select="format-number(CreditHoursEarned,$decfmt)"/></xsl:when>
                                            </xsl:choose>
                                        </TD>
                                        <TD CLASS="dddefault" align="right">
                                            <xsl:choose>
                                                <xsl:when test="(TotalQualityPoints)"><xsl:value-of select="format-number(TotalQualityPoints,$decfmt)"/></xsl:when>
                                            </xsl:choose>
                                        </TD>
                                    </TR>
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:otherwise>
                                <tr>
                                    <TD CLASS="dddefault" >&#160;</TD>
                                    <TD CLASS="dddefault" >&#160;</TD>
                                    <TD CLASS="dddefault"  >&#160;</TD>
                                    <TD CLASS="dddefault" >&#160;</TD>
                                    <TD CLASS="dddefault" >&#160;</TD>
                                    <TD CLASS="dddefault" >&#160;</TD>
                                </tr>
                            </xsl:otherwise>
                        </xsl:choose>
                    </table>
                </xsl:if>
            </div>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
