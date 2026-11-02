.class public abstract Lcom/pairip/licensecheck/ILicenseV2ResultListener$Stub;
.super Landroid/os/Binder;
.source "ILicenseV2ResultListener.java"

# interfaces
.implements Lcom/pairip/licensecheck/ILicenseV2ResultListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/pairip/licensecheck/ILicenseV2ResultListener;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x409
    name = "Stub"
.end annotation


# static fields
.field static final TRANSACTION_VERIFY_LICENSE:I = 0x1


# direct methods
.method public constructor <init>()V
    .registers 2

    #@0
    .line 47
    invoke-direct {p0}, Landroid/os/Binder;-><init>()V

    #@3
    .line 48
    const-string v0, "com.android.vending.licensing.ILicenseV2ResultListener"

    #@5
    invoke-virtual {p0, p0, v0}, Lcom/pairip/licensecheck/ILicenseV2ResultListener$Stub;->attachInterface(Landroid/os/IInterface;Ljava/lang/String;)V

    #@8
    return-void
.end method

.method private static readTypedObject(Landroid/os/Parcel;Landroid/os/Parcelable$Creator;)Ljava/lang/Object;
    .registers 3
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x0,
            0x0
        }
        names = {
            "parcel",
            "c"
        }
    .end annotation

    .annotation system Ldalvik/annotation/Signature;
        value = {
            "<T:",
            "Ljava/lang/Object;",
            ">(",
            "Landroid/os/Parcel;",
            "Landroid/os/Parcelable$Creator<",
            "TT;>;)TT;"
        }
    .end annotation

    #@0
    .line 84
    invoke-virtual {p0}, Landroid/os/Parcel;->readInt()I

    #@3
    move-result v0

    #@4
    if-eqz v0, :cond_b

    #@6
    .line 85
    invoke-interface {p1, p0}, Landroid/os/Parcelable$Creator;->createFromParcel(Landroid/os/Parcel;)Ljava/lang/Object;

    #@9
    move-result-object p0

    #@a
    goto :goto_c

    #@b
    :cond_b
    const/4 p0, 0x0

    #@c
    :goto_c
    return-object p0
.end method


# virtual methods
.method public asBinder()Landroid/os/IBinder;
    .registers 1

    #@0
    return-object p0
.end method

.method public onTransact(ILandroid/os/Parcel;Landroid/os/Parcel;I)Z
    .registers 8
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x0,
            0x0,
            0x0,
            0x0
        }
        names = {
            "code",
            "data",
            "reply",
            "flags"
        }
    .end annotation

    .annotation system Ldalvik/annotation/Throws;
        value = {
            Landroid/os/RemoteException;
        }
    .end annotation

    #@0
    .line 59
    const-string v0, "com.android.vending.licensing.ILicenseV2ResultListener"

    #@2
    const/4 v1, 0x1

    #@3
    if-lt p1, v1, :cond_d

    #@5
    const v2, 0xffffff

    #@8
    if-gt p1, v2, :cond_d

    #@a
    .line 60
    invoke-virtual {p2, v0}, Landroid/os/Parcel;->enforceInterface(Ljava/lang/String;)V

    #@d
    :cond_d
    if-eq p1, v1, :cond_1d

    #@f
    const v2, 0x5f4e5446

    #@12
    if-eq p1, v2, :cond_19

    #@14
    .line 77
    invoke-super {p0, p1, p2, p3, p4}, Landroid/os/Binder;->onTransact(ILandroid/os/Parcel;Landroid/os/Parcel;I)Z

    #@17
    move-result v1

    #@18
    goto :goto_2c

    #@19
    .line 65
    :cond_19
    invoke-virtual {p3, v0}, Landroid/os/Parcel;->writeString(Ljava/lang/String;)V

    #@1c
    goto :goto_2c

    #@1d
    .line 70
    :cond_1d
    invoke-virtual {p2}, Landroid/os/Parcel;->readInt()I

    #@20
    move-result p1

    #@21
    .line 71
    sget-object p3, Landroid/os/Bundle;->CREATOR:Landroid/os/Parcelable$Creator;

    #@23
    invoke-static {p2, p3}, Lcom/pairip/licensecheck/ILicenseV2ResultListener$Stub;->readTypedObject(Landroid/os/Parcel;Landroid/os/Parcelable$Creator;)Ljava/lang/Object;

    #@26
    move-result-object p2

    #@27
    check-cast p2, Landroid/os/Bundle;

    #@29
    .line 72
    invoke-virtual {p0, p1, p2}, Lcom/pairip/licensecheck/ILicenseV2ResultListener$Stub;->verifyLicense(ILandroid/os/Bundle;)V

    #@2c
    :goto_2c
    return v1
.end method
