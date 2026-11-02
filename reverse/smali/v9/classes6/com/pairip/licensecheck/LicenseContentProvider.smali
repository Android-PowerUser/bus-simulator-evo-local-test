.class public Lcom/pairip/licensecheck/LicenseContentProvider;
.super Landroid/content/ContentProvider;
.source "LicenseContentProvider.java"


# direct methods
.method public constructor <init>()V
    .registers 1

    #@0
    .line 9
    invoke-direct {p0}, Landroid/content/ContentProvider;-><init>()V

    #@3
    return-void
.end method


# virtual methods
.method public delete(Landroid/net/Uri;Ljava/lang/String;[Ljava/lang/String;)I
    .registers 4
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x0,
            0x0,
            0x0
        }
        names = {
            "uri",
            "selection",
            "selectionArgs"
        }
    .end annotation

    #@0
    .line 34
    new-instance p1, Ljava/lang/UnsupportedOperationException;

    #@2
    const-string p2, "Delete is not supported "

    #@4
    invoke-direct {p1, p2}, Ljava/lang/UnsupportedOperationException;-><init>(Ljava/lang/String;)V

    #@7
    throw p1
.end method

.method public getType(Landroid/net/Uri;)Ljava/lang/String;
    .registers 3
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x0
        }
        names = {
            "uri"
        }
    .end annotation

    #@0
    .line 24
    new-instance p1, Ljava/lang/UnsupportedOperationException;

    #@2
    const-string v0, "GetType is not supported "

    #@4
    invoke-direct {p1, v0}, Ljava/lang/UnsupportedOperationException;-><init>(Ljava/lang/String;)V

    #@7
    throw p1
.end method

.method public insert(Landroid/net/Uri;Landroid/content/ContentValues;)Landroid/net/Uri;
    .registers 3
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x0,
            0x0
        }
        names = {
            "uri",
            "values"
        }
    .end annotation

    #@0
    .line 29
    new-instance p1, Ljava/lang/UnsupportedOperationException;

    #@2
    const-string p2, "Insert is not supported "

    #@4
    invoke-direct {p1, p2}, Ljava/lang/UnsupportedOperationException;-><init>(Ljava/lang/String;)V

    #@7
    throw p1
.end method

.method public onCreate()Z
    .registers 2

    #@0
    .line 12
    invoke-virtual {p0}, Lcom/pairip/licensecheck/LicenseContentProvider;->getContext()Landroid/content/Context;

    #@3
    move-result-object v0

    #@4
    invoke-static {v0}, Lcom/pairip/licensecheck/LicenseClient;->checkLicense(Landroid/content/Context;)V

    #@7
    const/4 v0, 0x1

    #@8
    return v0
.end method

.method public query(Landroid/net/Uri;[Ljava/lang/String;Ljava/lang/String;[Ljava/lang/String;Ljava/lang/String;)Landroid/database/Cursor;
    .registers 6
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x0,
            0x0,
            0x0,
            0x0,
            0x0
        }
        names = {
            "uri",
            "projection",
            "selection",
            "selectionArgs",
            "sortOrder"
        }
    .end annotation

    #@0
    .line 19
    new-instance p1, Ljava/lang/UnsupportedOperationException;

    #@2
    const-string p2, "Query is not supported "

    #@4
    invoke-direct {p1, p2}, Ljava/lang/UnsupportedOperationException;-><init>(Ljava/lang/String;)V

    #@7
    throw p1
.end method

.method public update(Landroid/net/Uri;Landroid/content/ContentValues;Ljava/lang/String;[Ljava/lang/String;)I
    .registers 5
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x0,
            0x0,
            0x0,
            0x0
        }
        names = {
            "uri",
            "values",
            "selection",
            "selectionArgs"
        }
    .end annotation

    #@0
    .line 39
    new-instance p1, Ljava/lang/UnsupportedOperationException;

    #@2
    const-string p2, "Update is not supported "

    #@4
    invoke-direct {p1, p2}, Ljava/lang/UnsupportedOperationException;-><init>(Ljava/lang/String;)V

    #@7
    throw p1
.end method
